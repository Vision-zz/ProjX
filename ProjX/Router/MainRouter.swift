//
//  TabbarRouter.swift
//  ProjX
//
//  Created by Sathya on 27/04/23.
//

import UIKit

class MainRouter {

    private init() {}

    static let shared = MainRouter()

    weak var tabbarController: UITabBarController?
    weak var tasksVC: TasksVC?
    weak var teamsVC: TeamsVC?
    weak var profileVC: ProfileVC?

    func showUserAllTasks(of user: User, for signedInUser: User) {
        routeTabbarTo(index: 0)
        let filters = signedInUser.taskFilterSettings?.filters ?? Filters()
        filters.assignedTo = user.userID!
        filters.taskStatus = .unknown
        signedInUser.taskFilterSettings?.filters = filters
        DataManager.shared.saveContext()
        tasksVC?.updateView()
    }
    
    func showUserActiveTasks(of user: User, for signedInUser: User) {
        routeTabbarTo(index: 0)
        let filters = signedInUser.taskFilterSettings?.filters ?? Filters()
        filters.assignedTo = user.userID!
        filters.taskStatus = .inProgress
        signedInUser.taskFilterSettings?.filters = filters
        DataManager.shared.saveContext()
        tasksVC?.updateView()
    }
    
    func showAllTeamTasks(for signedInUser: User) {
        routeTabbarTo(index: 0)
        let filters = signedInUser.taskFilterSettings?.filters ?? Filters()
        filters.assignedTo = nil
        filters.createdBy = nil
        filters.createdBetween = nil
        filters.etaBetween = nil
        filters.taskStatus = .unknown
        signedInUser.taskFilterSettings?.filters = filters
        DataManager.shared.saveContext()
        tasksVC?.updateView()
    }
    
    func showActiveTeamTasks(for signedInUser: User) {
        routeTabbarTo(index: 0)
        let filters = signedInUser.taskFilterSettings?.filters ?? Filters()
        filters.assignedTo = nil
        filters.createdBy = nil
        filters.createdBetween = nil
        filters.etaBetween = nil
        filters.taskStatus = .complete
        signedInUser.taskFilterSettings?.filters = filters
        DataManager.shared.saveContext()
        tasksVC?.updateView()
    }
    
    func routeTabbarTo(index: Int) {
        tabbarController?.selectedIndex = index
    }

    func routeToWelcomePage() {
        GlobalConstants.StructureDelegates.sceneDelegate?.switchToWelcomePageVC()
    }

    func routeToHomePage() {
        GlobalConstants.StructureDelegates.sceneDelegate?.switchToHomePageVC()
    }
}
