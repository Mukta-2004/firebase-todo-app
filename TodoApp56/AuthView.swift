import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Todo List")
                            .font(.custom("Arial-BoldMT", size: 34, relativeTo: .largeTitle))
                        Text(isSignUp ? "Create your account" : "Sign in to your account")
                            .font(.custom("Arial", size: 16, relativeTo: .subheadline))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 44)
                    .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.custom("Arial-BoldMT", size: 14, relativeTo: .subheadline))
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                                .padding(14)
                                .background(.background, in: RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("Email")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.custom("Arial-BoldMT", size: 14, relativeTo: .subheadline))
                            SecureField("Enter your password", text: $password)
                                .textContentType(isSignUp ? .newPassword : .password)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit { authenticate() }
                                .padding(14)
                                .background(.background, in: RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("Password")
                        }

                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .font(.custom("Arial", size: 14, relativeTo: .subheadline))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityIdentifier("authError")
                        }
                    }

                    VStack(spacing: 8) {
                        Button(action: authenticate) {
                            HStack(spacing: 10) {
                                if auth.isLoading {
                                    ProgressView()
                                }
                                Text(isSignUp ? "Sign Up" : "Sign In")
                                    .font(.custom("Arial-BoldMT", size: 17, relativeTo: .headline))
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(AppTheme.babyPink, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(AppTheme.accent)

                        Button(isSignUp ? "Already have an account? Sign In" : "Sign Up") {
                            isSignUp.toggle()
                            password = ""
                            auth.errorMessage = ""
                            focusedField = nil
                        }
                        .font(.custom("Arial", size: 15, relativeTo: .subheadline))
                        .frame(minHeight: 44)
                    }
                }
                .padding(24)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
                .disabled(auth.isLoading)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    // Dismiss the keyboard before checking the account details.
    private func authenticate() {
        guard !auth.isLoading else { return }
        focusedField = nil
        Task {
            await auth.authenticate(email: email, password: password, isSignUp: isSignUp)
        }
    }
}
