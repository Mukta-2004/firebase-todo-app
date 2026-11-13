import SwiftUI
import FirebaseAuth
import FirebaseCore
import UIKit

@main
struct TodoApp56App: App {
    // Connect Firebase before any view models use it.
    init() {
        FirebaseApp.configure()

        let navigation = UINavigationBar.appearance()
        navigation.largeTitleTextAttributes = [
            .font: UIFont(name: "Arial-BoldMT", size: 34)!
        ]
        navigation.titleTextAttributes = [
            .font: UIFont(name: "Arial-BoldMT", size: 17)!
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: UIFont(name: "Arial", size: 17)!
        ], for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .font(.custom("Arial", size: 17, relativeTo: .body))
                .tint(AppTheme.accent)
        }
    }
}

private struct RootView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        Group {
            if auth.isCheckingSession {
                ProgressView("Opening your list…")
            } else if let user = auth.user {
                TaskListView(userId: user.uid)
                    .id(user.uid)
            } else {
                AuthView()
            }
        }
        .environmentObject(auth)
    }
}
