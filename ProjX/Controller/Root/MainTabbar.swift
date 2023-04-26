//
//  MainTabbarVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class MainTabbar: UITabBarController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotifCenter()
        configureTabbar()
    }

    private func configureNotifCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
    }
    
    let browse = UINavigationController(rootViewController: TasksVC())
    let team = UINavigationController(rootViewController: TeamsVC())
    let profile = UINavigationController(rootViewController: ProfileVC())

    private func configureTabbar() {


        browse.tabBarItem.image = UIImage(systemName: "rectangle.stack")
        browse.tabBarItem.selectedImage = UIImage(systemName: "rectangle.stack.fill")
        browse.title = "Tasks"
        browse.navigationBar.prefersLargeTitles = true

        team.tabBarItem.image = UIImage(systemName: "person.2")
        team.tabBarItem.selectedImage = UIImage(systemName: "person.2.fill")
        team.title = "Teams"
        team.navigationBar.prefersLargeTitles = true

        profile.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        profile.tabBarItem.selectedImage = UIImage(systemName: "person.crop.circle.fill")
        profile.title = "Profile"
        profile.navigationBar.prefersLargeTitles = true

        self.tabBar.tintColor = GlobalConstants.Colors.accentColor
        self.tabBar.unselectedItemTintColor = .label
        self.tabBar.isTranslucent = true
        updateAccentColor()
        self.viewControllers = [browse, team, profile]

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.865, y: 0.865)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: 0.3)
        propertyAnimator.startAnimation()
    }

    @objc private func updateTheme() {
        self.tabBar.tintColor = GlobalConstants.Colors.accentColor
        updateAccentColor()
        print("Done main tabbar")
    }

    private func updateAccentColor() {
        browse.navigationBar.tintColor = GlobalConstants.Colors.accentColor
        team.navigationBar.tintColor = GlobalConstants.Colors.accentColor
        profile.navigationBar.tintColor = GlobalConstants.Colors.accentColor
    }


}

