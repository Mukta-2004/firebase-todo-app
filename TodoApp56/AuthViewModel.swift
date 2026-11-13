import Combine
import FirebaseAuth
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isCheckingSession = true
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var authListener: AuthStateDidChangeListenerHandle?

    // Watch for sign-in, sign-out, and a saved login session.
    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isCheckingSession = false
            }
        }
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    // Check the form, then sign in or create an account.
    func authenticate(email: String, password: String, isSignUp: Bool) async {
        errorMessage = ""
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        guard !isSignUp || password.count >= 6 else {
            errorMessage = "Please use a password with at least 6 characters."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if isSignUp {
                _ = try await Auth.auth().createUser(withEmail: email, password: password)
            } else {
                _ = try await Auth.auth().signIn(withEmail: email, password: password)
            }
        } catch {
            errorMessage = message(for: error)
        }
    }

    // End the current session and return to the login screen.
    func signOut() {
        errorMessage = ""
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    // Turn common Firebase errors into short messages.
    private func message(for error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword, .invalidCredential, .userNotFound:
            return "The email or password is incorrect. Please try again."
        case .weakPassword:
            return "This password is too weak. Please choose a stronger password."
        case .emailAlreadyInUse:
            return "This email already has an account. Please sign in."
        case .networkError:
            return "Check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .userDisabled:
            return "This account has been disabled."
        default:
            return error.localizedDescription
        }
    }
}
