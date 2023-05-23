//
//  ReassignDelegates.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import Foundation

protocol ReassignForWholeTeamDelegate: AnyObject {
    func reassigned(for team: Team)
}

protocol ReassignForTaskDelegate: AnyObject {
    func reassinged(for task: TaskItem)
}

protocol ReassignOptionSelectionDelegate: AnyObject {
    func selected(user: User, for tasks: [TaskItem], in team: Team)
    func selected(option: ReassignTaskOptions, for tasks: [TaskItem], in team: Team)
}

protocol ReloadDelegate: AnyObject {
    func reloadData()
}

protocol LeaveTeamDelegate: AnyObject {
    func leftTeamAfterReassigning()
}
