import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage = ""

    private let database = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var listeningUserId: String?

    // Listen only to documents belonging to this user.
    func startListening(userId: String) {
        stopListening()
        listeningUserId = userId
        isLoading = true
        errorMessage = ""

        listener = database.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self, self.listeningUserId == userId else { return }
                    self.isLoading = false

                    if let error {
                        self.errorMessage = "Could not load tasks: \(error.localizedDescription)"
                        return
                    }

                    self.errorMessage = ""
                    self.tasks = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        guard let title = data["title"] as? String,
                              let description = data["description"] as? String,
                              let owner = data["userId"] as? String,
                              owner == userId else { return nil }

                        return TodoTask(id: document.documentID, title: title,
                                        description: description, userId: owner)
                    }.sorted { $0.id < $1.id } ?? []
                }
            }
    }

    // Remove the listener and clear the previous user's tasks.
    func stopListening() {
        listener?.remove()
        listener = nil
        listeningUserId = nil
        tasks = []
    }

    deinit {
        listener?.remove()
    }

    // Save a new task or update the task opened for editing.
    func saveTask(title: String, description: String, task: TodoTask?,
                  userId: String) async throws {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw NSError(domain: "Tasks", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Please enter a title."])
        }
        guard Auth.auth().currentUser?.uid == userId,
              task == nil || task?.userId == userId else {
            throw NSError(domain: "Tasks", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Please sign in again."])
        }

        let data: [String: Any] = [
            "title": title,
            "description": description.trimmingCharacters(in: .whitespacesAndNewlines),
            "userId": userId
        ]

        if let task {
            try await database.collection("tasks").document(task.id).updateData(data)
        } else {
            _ = try await database.collection("tasks").addDocument(data: data)
        }
    }

    // Delete one task; the listener will refresh the list.
    func deleteTask(_ task: TodoTask) async {
        guard Auth.auth().currentUser?.uid == task.userId else {
            errorMessage = "Please sign in again before deleting a task."
            return
        }

        errorMessage = ""
        do {
            try await database.collection("tasks").document(task.id).delete()
        } catch {
            errorMessage = "Could not delete task: \(error.localizedDescription)"
        }
    }
}
