//
//  TaskItem+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 15/05/23.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var assignedTo: UUID?
    @NSManaged public var completedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdBy: UUID?
    @NSManaged public var deadline: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskID: UUID?
    @NSManaged public var taskStatusID: Int16
    @NSManaged public var title: String?
    @NSManaged public var updates: NSSet?

}

// MARK: Generated accessors for updates
extension TaskItem {

    @objc(addUpdatesObject:)
    @NSManaged public func addToUpdates(_ value: TaskStatusUpdate)

    @objc(removeUpdatesObject:)
    @NSManaged public func removeFromUpdates(_ value: TaskStatusUpdate)

    @objc(addUpdates:)
    @NSManaged public func addToUpdates(_ values: NSSet)

    @objc(removeUpdates:)
    @NSManaged public func removeFromUpdates(_ values: NSSet)

}

extension TaskItem : Identifiable {

}
