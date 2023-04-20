//
//  TaskDelegates.swift
//  ProjX
//
//  Created by Sathya on 17/04/23.
//

import Foundation

protocol AssignedToSelectionDelegate: AnyObject {
    func taskAssigned(to user: User)
}

protocol PriorityPickerDelegate: AnyObject {
    func selectedPriority(_ priority: TaskPriority)
}

protocol CreateTaskDelegate: AnyObject {
    func taskCreated(_ task: TaskItem)
}
