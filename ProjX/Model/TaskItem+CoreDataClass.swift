//
//  TaskItem+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 06/04/23.
//
//

import Foundation
import CoreData


public class TaskItem: NSManagedObject {

    public override var description: String {
        "TaskItem"
    }

    var taskStatus: TaskStatus {
        get {
            let rawValue = taskStatusID < 0 ? 0 : taskStatusID
            return TaskStatus.init(rawValue: rawValue)!
        }
        set {
            taskStatusID = newValue.rawValue
        }
    }

    var taskPriority: TaskPriority {
        get {
            let rawValue = priority < 0 ? 0 : priority
            return TaskPriority.init(rawValue: rawValue)!
        }
        set {
            priority = newValue.rawValue
        }
    }

    var assignedToUser: User? {
        get {
            guard let assignedTo = assignedTo else { return nil }
            return DataManager.shared.getUserMatching({ $0.userID == assignedTo })
        }
        set {
            assignedTo = newValue?.userID
        }
    }

    var createdByUser: User {
        get {
            return DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == createdBy })!
        }
        set {
            createdBy = newValue.userID
        }
    }

    func markTaskAsCompleted() {
        taskStatus = .complete
        completedAt = Date()
        DataManager.shared.saveContext()
    }

}
