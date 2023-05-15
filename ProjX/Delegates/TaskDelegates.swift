//
//  TaskDelegates.swift
//  ProjX
//
//  Created by Sathya on 17/04/23.
//

import Foundation

@objc protocol MemberSelectionDelegate: AnyObject {
    func selected(user: User)
    @objc optional func clearedSelection()
}

protocol PriorityPickerDelegate: AnyObject {
    func selectedPriority(_ priority: TaskPriority, dismiss: Bool)
}

protocol TaskStatusPickerDelegate: AnyObject {
    func selectedStatus(_ status: TaskStatus, dismiss: Bool)
}

protocol CreateTaskDelegate: AnyObject {
    func taskCreatedOrUpdated(_ task: TaskItem)
}
