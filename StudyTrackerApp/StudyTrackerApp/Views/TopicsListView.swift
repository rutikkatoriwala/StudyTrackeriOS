import SwiftUI
import CoreData

struct TopicsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("topicSortOrder") private var sortOrder = "date_desc"

    @StateObject private var vm: TopicsListViewModel

    init() {
        _vm = StateObject(
            wrappedValue: TopicsListViewModel(
                context: PersistenceController.shared.container.viewContext
            )
        )
    }

    var body: some View {
        NavigationView {
            Group {
                if vm.topics.isEmpty {
                    Text("No topics available")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(vm.topics, id: \.objectID) { topic in
                            NavigationLink {
                                TopicDetailView(topic: topic)   // ✅ lazy
                            } label: {
                                TopicRowView(topic: topic)
                            }
                        }
                        .onDelete(perform: vm.delete)
                    }
                }
            }
            .navigationTitle("All Topics")
            .onAppear { vm.fetchTopics(sortOrder: sortOrder) }
            .onChange(of: sortOrder) { newValue in
                vm.fetchTopics(sortOrder: newValue)
            }
        }
    }
}
