import SwiftUI

struct TaskListView: View {
    let userId: String

    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var isShowingForm = false
    @State private var selectedTask: TodoTask?

    var body: some View {
        NavigationView {
            List {
                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundStyle(.red)
                }

                if !taskViewModel.errorMessage.isEmpty {
                    Text(taskViewModel.errorMessage)
                        .foregroundStyle(.red)
                    Button("Retry loading tasks") {
                        taskViewModel.startListening(userId: userId)
                    }
                }

                if taskViewModel.isLoading {
                    ProgressView("Loading tasks…")
                } else if taskViewModel.tasks.isEmpty && taskViewModel.errorMessage.isEmpty {
                    Text("No tasks yet. Tap New task+ to add one.")
                        .foregroundStyle(.secondary)
                }

                ForEach(taskViewModel.tasks) { task in
                    Button {
                        selectedTask = task
                        isShowingForm = true
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.custom("Arial-BoldMT", size: 17, relativeTo: .headline))
                                .foregroundStyle(.primary)
                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.custom("Arial", size: 15, relativeTo: .subheadline))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the task for editing")
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            Task { await taskViewModel.deleteTask(task) }
                        }
                        Button("Edit") {
                            selectedTask = task
                            isShowingForm = true
                        }
                        .tint(AppTheme.accent)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") { auth.signOut() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New task+") { openNewTask() }
                }
            }
            .sheet(isPresented: $isShowingForm) {
                TaskFormView(taskViewModel: taskViewModel, userId: userId,
                             task: selectedTask, isPresented: $isShowingForm)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { taskViewModel.startListening(userId: userId) }
        .onDisappear { taskViewModel.stopListening() }
    }

    // Clear the selection before opening a blank form.
    private func openNewTask() {
        selectedTask = nil
        isShowingForm = true
    }
}
