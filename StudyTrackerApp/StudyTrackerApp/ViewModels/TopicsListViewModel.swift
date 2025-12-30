import Foundation
import CoreData

class TopicsListViewModel: ObservableObject {
    @Published var topics: [Topic] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTopics(sortOrder: "date_desc")
    }

    func fetchTopics(sortOrder: String) {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()

        switch sortOrder {
        case "date_asc":
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        case "expected_asc":
            request.sortDescriptors = [NSSortDescriptor(key: "expectedTime", ascending: true)]
        case "expected_desc":
            request.sortDescriptors = [NSSortDescriptor(key: "expectedTime", ascending: false)]
        default:
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        }

        do {
            topics = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            context.delete(topics[index])
        }
        try? context.save()
        topics.remove(atOffsets: indexSet)
    }
}
