//
//  TaskItem+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 23/03/23.
//
//

import Foundation
import CoreData


extension TaskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItem> {
        return NSFetchRequest<TaskItem>(entityName: "TaskItem")
    }

    @NSManaged public var assignedTo: User?
    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdBy: User?
    @NSManaged public var deadline: Date?
    @NSManaged public var statusUpdates: [StatusUpdate]?
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskID: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskStatusID: Int16

}

extension TaskItem : Identifiable {

}
