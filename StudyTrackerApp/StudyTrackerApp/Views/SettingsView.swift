import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("topicSortOrder") private var sortOrder = "date_desc"
    @State private var showClearAlert = false   // 👈 added

    var body: some View {
        NavigationView {
            Form {
                // MARK: Sorting section
                Section(header: Text("Topic list")) {
                    Picker("Sort topics by", selection: $sortOrder) {
                        Text("Newest first").tag("date_desc")
                        Text("Oldest first").tag("date_asc")
                        Text("Expected time (asc)").tag("expected_asc")
                        Text("Expected time (desc)").tag("expected_desc")
                    }
                }

                // MARK: App section
                Section(header: Text("App")) {
                    Button("Clear all completed topics") {
                        showClearAlert = true   // 👈 trigger alert
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Confirm Deletion", isPresented: $showClearAlert) {
                Button("Delete", role: .destructive) {
                    clearCompleted()          // 👈 delete after confirmation
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all completed topics? This action cannot be undone.")
            }
        }
    }

    private func clearCompleted() {
        let ctx = PersistenceController.shared.container.viewContext
        let fr: NSFetchRequest<Topic> = Topic.fetchRequest()
        fr.predicate = NSPredicate(format: "isCompleted == YES")
        if let completed = try? ctx.fetch(fr) {
            completed.forEach { ctx.delete($0) }
            try? ctx.save()
        }
    }
}
