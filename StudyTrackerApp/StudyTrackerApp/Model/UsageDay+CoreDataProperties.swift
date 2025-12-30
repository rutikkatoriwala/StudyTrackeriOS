// UsageDay+CoreDataProperties.swift
import Foundation
import CoreData

extension UsageDay {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsageDay> {
        return NSFetchRequest<UsageDay>(entityName: "UsageDay")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
}

extension UsageDay : Identifiable { }
