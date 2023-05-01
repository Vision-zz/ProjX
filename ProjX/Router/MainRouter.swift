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

    func routeTabbarTo(index: Int) {
        tabbarController?.selectedIndex = index
    }

    func switchTasksSegmentedControlTo(option: TasksVC.AvailableSegmentControlDisplayOptions) {
        tasksVC?.switchSegmentControl(to: option)
    }

    func routeToWelcomePage() {
        GlobalConstants.StructureDelegates.sceneDelegate?.switchToWelcomePageVC()
    }

    func routeToHomePage() {
        GlobalConstants.StructureDelegates.sceneDelegate?.switchToHomePageVC()
    }
}
