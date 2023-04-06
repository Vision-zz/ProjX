//
//  MainTabbarVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class MainTabbar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
    }

    private func configureTabbar() {

//        let home = UINavigationController(rootViewController: HomeVC())
        let browse = UINavigationController(rootViewController: TasksVC())
        let team = UINavigationController(rootViewController: TeamsVC())
        let updates = UINavigationController(rootViewController: UpdatesVC())
        let profile = UINavigationController(rootViewController: ProfileVC())

//        home.tabBarItem.image = UIImage(systemName: "house")
//        home.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
//        home.title = "Home"
//        home.navigationBar.prefersLargeTitles = true

        browse.tabBarItem.image = UIImage(systemName: "rectangle.stack")
        browse.tabBarItem.selectedImage = UIImage(systemName: "rectangle.stack.fill")
        browse.title = "Tasks"
        browse.navigationBar.prefersLargeTitles = true

        team.tabBarItem.image = UIImage(systemName: "person.2")
        team.tabBarItem.selectedImage = UIImage(systemName: "person.2.fill")
        team.title = "Team"
        team.navigationBar.prefersLargeTitles = true

        updates.tabBarItem.image = UIImage(systemName: "bell")
        updates.tabBarItem.selectedImage = UIImage(systemName: "bell.fill")
        updates.title = "Updates"
        updates.navigationBar.prefersLargeTitles = true

        profile.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        profile.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        profile.title = "Profile"
        profile.navigationBar.prefersLargeTitles = true

        self.tabBar.tintColor = .label
        self.tabBar.isTranslucent = true
        self.viewControllers = [browse, team, updates, profile]

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.865, y: 0.865)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: 0.3)
        propertyAnimator.startAnimation()
    }

}
