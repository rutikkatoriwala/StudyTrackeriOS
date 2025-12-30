// TopicViewModel.swift
import Foundation
import CoreData
import Combine

class TopicViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var topics: [Topic] = []
    private var fetchRequest: NSFetchRequest<Topic>

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchRequest = Topic.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetch()
    }

    func fetch() {
        do {
            topics = try context.fetch(fetchRequest)
        } catch {
            print("Fetch error: \(error)")
            topics = []
        }
    }

    func addTopic(title: String, expected: TimeInterval) {
        let t = Topic(context: context)
        t.id = UUID()
        t.title = title
        t.expectedTime = expected
        t.actualTime = 0
        t.isCompleted = false
        t.createdAt = Date()

        saveContext()
        fetch()
    }

    func deleteTopic(_ topic: Topic) {
        context.delete(topic)
        saveContext()
        fetch()
    }

    func saveContext() {
        do {
            if context.hasChanges { try context.save() }
        } catch {
            print("Save error: \(error)")
            context.rollback()
        }
    }
}
