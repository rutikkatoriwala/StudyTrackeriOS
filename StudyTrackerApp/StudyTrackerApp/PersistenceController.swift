// PersistenceController.swift
import Foundation
import CoreData

/// Central Core Data stack used across the app.
/// - Make sure your .xcdatamodeld is named "StudyTrackrModel" (or update the name below).
/// - Ensure each entity's Codegen is set to "Manual/None" if you are using manual NSManagedObject subclasses.
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "StudyTrackrModel ")

        if inMemory {
            // redirect to dev/null for preview/in-memory usage
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // make sure there is at least one store description
            if container.persistentStoreDescriptions.isEmpty {
                let description = NSPersistentStoreDescription()
                container.persistentStoreDescriptions = [description]
            }
        }

        container.loadPersistentStores { storeDescription, loadError in
            if let loadError = loadError as NSError? {
                // A fatalError here is appropriate during development so you notice model errors.
                fatalError("Unresolved Core Data load error \(loadError), \(loadError.userInfo)")
            }
        }

        // Recommended conveniences
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Save helper for the viewContext
    func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }

    // MARK: - Preview / in-memory sample data for SwiftUI Previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        // Sample data safe creation — adjust attributes to match your model
        for i in 0..<3 {
            let t = Topic(context: ctx)
            t.id = UUID()
            t.title = "Sample Topic \(i + 1)"
            t.expectedTime = Double(30 * 60) // 30 minutes
            t.actualTime = Double((i + 1) * 10 * 60) // sample actuals
            t.isCompleted = (i % 2 == 0)
            t.createdAt = Date().addingTimeInterval(TimeInterval(-3600 * 24 * i))

            if t.isCompleted {
                // Create a stop log so analytics can pick up a completion timestamp
                let stop = LogEvent(context: ctx)
                stop.id = UUID()
                stop.type = "stop"
                stop.timestamp = Date().addingTimeInterval(TimeInterval(-3600 * 24 * i))
                stop.elapsedAtEvent = t.actualTime
                stop.pauseDuration = 0
                stop.topic = t
            }
        }

        do {
            try ctx.save()
        } catch {
            // avoid shadowing a variable named `error` in outer scopes — name it previewSaveError
            let previewSaveError = error
            print("Preview save error: \(previewSaveError.localizedDescription)")
        }

        return controller
    }()
}
