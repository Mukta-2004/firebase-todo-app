# Todo List

A small SwiftUI app for the Mobile Computing lab. Users can create an account, sign in, and manage their own tasks. The interface uses a baby pink background, Arial font, and standard iOS forms and navigation. The screens keep only the essential fields and buttons, with a plain task list and consistent spacing. The pink colors also adapt to Dark Mode.

## Run the app

1. Open `TodoApp56.xcodeproj` in Xcode. This project currently targets iOS 26.5 or later.
2. Let Xcode finish resolving the Firebase packages. FirebaseAuth, FirebaseCore, and FirebaseFirestore are already added.
3. In the Firebase Console, open the project connected to `GoogleService-Info.plist`. Under **Authentication → Sign-in method**, enable **Email/Password**.
4. Create a **Cloud Firestore** database. Under its **Rules** tab, paste the contents of `firestore.rules` and publish them. These short rules let each user access only their own tasks.
5. Select an iPhone simulator and press Run. For a physical iPhone, select your signing team in **Signing & Capabilities** first.

The included Firebase plist matches the bundle ID `com.mukta.cpp.TodoApp56`. If you use another Firebase project, register an iOS app with that bundle ID, then replace the plist with the downloaded file. Keep it inside the `TodoApp56` folder so Xcode bundles it.

The app creates documents in `tasks` when you save your first task. You do not need to create the collection by hand.

## Files

| File | Purpose |
| --- | --- |
| `TodoApp56/TodoApp56App.swift` | Starts Firebase and chooses the login screen or task list. |
| `TodoApp56/AuthViewModel.swift` | Handles signup, login, logout, session changes, and login errors. |
| `TodoApp56/TaskViewModel.swift` | Listens for task changes and handles create, update, and delete. |
| `TodoApp56/TodoTask.swift` | Holds a task's ID, title, description, and user ID. |
| `TodoApp56/AuthView.swift` | Email and password form with Sign In and Sign Up modes. |
| `TodoApp56/TaskListView.swift` | Shows My Tasks, New task+, Sign Out, and swipe actions. |
| `TodoApp56/TaskFormView.swift` | Shared Add/Edit form with Save and Cancel. |
| `TodoApp56/AppTheme.swift` | Defines the pink colors used by the screens. |
| `firestore.rules` | Basic owner-only access rules to publish in Firebase. |

## How it works

Firebase Authentication remembers the login session. An auth listener checks it when the app opens, so a signed-in user goes straight to My Tasks.

Each Firestore document has three fields: `title` (String), `description` (String), and `userId` (String). The document ID becomes the task's `id` in Swift. The query uses `whereField("userId", isEqualTo: userId)`, and a snapshot listener refreshes the list whenever matching documents change. The listener is removed when the list closes.

`@State` holds text field values, form visibility, and loading messages. `@Binding` lets the task form close the sheet owned by the list. `@StateObject` keeps the view models alive, `@ObservedObject` shares the task model with the form, and `@EnvironmentObject` shares the auth model across screens. `NavigationView` provides titles and toolbar buttons; a sheet opens the task form.

## Try it

- Submit empty login fields and check the error message.
- Switch to Sign Up. Try a password shorter than six characters, then create an account with a valid email and stronger password.
- Add a title and description. A blank or spaces-only title keeps Save disabled.
- Tap a task to edit it. Save changes, then reopen it and try Cancel.
- Swipe left on a task to edit or delete it.
- Close and reopen the app while signed in. It should restore your session.
- Sign out and try an incorrect password. The error should appear below the fields.
- Create a second account and check that it has a separate task list.
- Change one of your tasks in the Firestore Console while the app is open. The list should update automatically.

An internet connection is needed for authentication and server-confirmed saves. If a save is waiting for a connection, the form stays open until Firebase confirms the write or reports an error.

## Checked locally

The Debug build passed for the iPhone 17 Pro simulator on iOS 26.5. The app opened successfully, switched between Sign In and Sign Up, and displayed the empty-field and short-password errors. Live signup, login, and task operations still need to be checked after the Firebase Console setup above.

Firebase references: [Email/password authentication](https://firebase.google.com/docs/auth/ios/password-auth) and [Firestore snapshot listeners](https://firebase.google.com/docs/firestore/query-data/listen).
