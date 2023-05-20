//
//  TaskStatusUpdate+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 15/05/23.
//
//

import Foundation
import CoreData


extension TaskStatusUpdate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskStatusUpdate> {
        return NSFetchRequest<TaskStatusUpdate>(entityName: "TaskStatusUpdate")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var statusDescription: String?
    @NSManaged public var subject: String?
    @NSManaged public var task: TaskItem?

}

extension TaskStatusUpdate : Identifiable {

}
