import SwiftUI

struct TaskFormView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    let userId: String
    let task: TodoTask?
    @Binding var isPresented: Bool

    @State private var title: String
    @State private var description: String
    @State private var isSaving = false
    @State private var errorMessage = ""

    // Fill in the fields when editing, or leave them empty for a new task.
    init(taskViewModel: TaskViewModel, userId: String, task: TodoTask?,
         isPresented: Binding<Bool>) {
        self.taskViewModel = taskViewModel
        self.userId = userId
        self.task = task
        self._isPresented = isPresented
        self._title = State(initialValue: task?.title ?? "")
        self._description = State(initialValue: task?.description ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.custom("Arial-BoldMT", size: 14, relativeTo: .subheadline))
                        TextField("Enter a title", text: $title)
                            .accessibilityLabel("Title")
                    }
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.custom("Arial-BoldMT", size: 14, relativeTo: .subheadline))
                        TextField("Enter a description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .accessibilityLabel("Description")
                    }
                    .padding(.vertical, 8)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                if isSaving {
                    ProgressView("Saving…")
                }
            }
            .disabled(isSaving)
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle(task == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled(isSaving)
    }

    // Close the form only after Firebase accepts the save.
    private func save() async {
        isSaving = true
        errorMessage = ""
        defer { isSaving = false }

        do {
            try await taskViewModel.saveTask(title: title, description: description,
                                             task: task, userId: userId)
            isPresented = false
        } catch {
            errorMessage = "Could not save task: \(error.localizedDescription)"
        }
    }
}
