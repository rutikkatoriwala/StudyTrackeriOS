// Topic+CoreDataProperties.swift
import Foundation
import CoreData

extension Topic {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Topic> {
        return NSFetchRequest<Topic>(entityName: "Topic")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var expectedTime: Double
    @NSManaged public var actualTime: Double
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var logEvents: NSSet?
}

// MARK: Generated accessors for logEvents
extension Topic {
    @objc(addLogEventsObject:)
    @NSManaged public func addToLogEvents(_ value: LogEvent)

    @objc(removeLogEventsObject:)
    @NSManaged public func removeFromLogEvents(_ value: LogEvent)

    @objc(addLogEvents:)
    @NSManaged public func addToLogEvents(_ values: NSSet)

    @objc(removeLogEvents:)
    @NSManaged public func removeFromLogEvents(_ values: NSSet)
}

extension Topic : Identifiable { }
