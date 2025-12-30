// LogEvent+CoreDataProperties.swift
import Foundation
import CoreData

extension LogEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogEvent> {
        return NSFetchRequest<LogEvent>(entityName: "LogEvent")
    }

    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var timestamp: Date
    @NSManaged public var elapsedAtEvent: Double
    @NSManaged public var pauseDuration: Double
    @NSManaged public var topic: Topic?
}

extension LogEvent : Identifiable { }
