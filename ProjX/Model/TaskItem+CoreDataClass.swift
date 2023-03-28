//
//  TaskItem+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 23/03/23.
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

}
