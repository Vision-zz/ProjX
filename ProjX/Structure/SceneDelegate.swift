//
//  SceneDelegate.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {


    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        DataConfiguration.configureStuff(force: false)

        let userID = UserDefaults.standard.string(forKey: GlobalConstants.UserDefaultsKey.currentLoggedInUserID)
        let users = DataManager.shared.getAllUsers()
        let signedInUser = users.first(where: { $0.userID != nil && $0.userID!.uuidString == userID })
        if let signedInUser = signedInUser {
            SessionManager.shared.signedInUser = signedInUser
            window?.rootViewController = MainTabbar()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: WelcomePage())
        }

        changeUserInterfaceStyle()
        window?.makeKeyAndVisible()
    }

    func switchToWelcomePageVC() {
        guard let window = window else { return }
        window.rootViewController = UINavigationController(rootViewController: WelcomePage())
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve, .preferredFramesPerSecond60], animations: nil, completion: nil)
    }

    func switchToHomePageVC() {
        guard let window = window else { return }
        window.rootViewController = MainTabbar()
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve, .preferredFramesPerSecond60], animations: nil, completion: nil)
    }

    func changeUserInterfaceStyle() {
        let theme = GlobalConstants.Device.selectedTheme
        window?.overrideUserInterfaceStyle = theme == .light ? .light : theme == .dark ? .dark : .unspecified
    }

    func switchAccentColor() {
        guard let window = window else { return }
        if let _ = SessionManager.shared.signedInUser {
            window.rootViewController = MainTabbar()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }


}

