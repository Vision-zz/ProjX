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
    func selectedPriority(_ priority: TaskPriority, dismiss: Bool)
}

protocol CreateTaskDelegate: AnyObject {
    func taskCreatedOrUpdated(_ task: TaskItem)
}
