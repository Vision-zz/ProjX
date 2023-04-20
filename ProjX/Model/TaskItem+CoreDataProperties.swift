//
//  TaskItem+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 06/04/23.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var priority: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var completedAt: Date?
    @NSManaged public var statusUpdates: [StatusUpdate]?
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskID: UUID?
    @NSManaged public var taskStatusID: Int16
    @NSManaged public var title: String?
    @NSManaged public var createdBy: UUID?
    @NSManaged public var assignedTo: UUID?

}

extension TaskItem : Identifiable {

}
