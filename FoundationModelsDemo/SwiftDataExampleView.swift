import SwiftUI
import SwiftData

// @Model makes this class persistable and tracks changes to its properties.
@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(title: String) {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}

struct SwiftDataExampleView: View {
    @Environment(\.modelContext) private var modelContext
    // The list refreshes automatically when stored items change.
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var items: [TodoItem]
    @State private var newTitle = ""
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Add a task") {
                    TextField("Task title", text: $newTitle)
                        .onSubmit(addItem)
                    Button("Add task", systemImage: "plus", action: addItem)
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Saved tasks") {
                    if items.isEmpty {
                        Text("Add your first task. Tasks stay saved after you close the app.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items) { item in
                        Button {
                            // Updating a model property is enough to mark it changed.
                            item.isCompleted.toggle()
                            saveChanges()
                        } label: {
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isCompleted ? Color.green : Color.secondary)
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.title)
                        .accessibilityValue(item.isCompleted ? "Completed" : "Incomplete")
                        .accessibilityHint("Toggle completion")
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("SwiftData Tasks")
            .toolbar { EditButton() }
            .alert("Could not save changes", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    private func addItem() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        modelContext.insert(TodoItem(title: title))
        if saveChanges() { newTitle = "" }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
        saveChanges()
    }

    @discardableResult
    private func saveChanges() -> Bool {
        do {
            // Explicit saving lets the example report persistence failures.
            try modelContext.save()
            return true
        } catch {
            modelContext.rollback()
            saveError = error.localizedDescription
            return false
        }
    }
}

#Preview {
    SwiftDataExampleView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
