//
//  SceneDelegate.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var shared: SceneDelegate?
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      SceneDelegate.shared = self
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

//        window?.rootViewController = UINavigationController(rootViewController: DummyVC())

        let userID = UserDefaults.standard.string(forKey: GlobalConstants.UserDefaultsKey.currentLoggedInUserID)
        let users = DataManager.shared.getAllUsers()
        let signedInUser = users.first(where: { $0.userID != nil && $0.userID!.uuidString == userID })
        if let signedInUser = signedInUser {
            SessionManager.shared.signedInUser = signedInUser
            window?.rootViewController = UINavigationController(rootViewController: MainTabbar())
        } else {
            window?.rootViewController = UINavigationController(rootViewController: WelcomePage())
        }
        window?.makeKeyAndVisible()
    }

    func switchToWelcomePageVC() {
        guard let window = window else { return }
        window.rootViewController = UINavigationController(rootViewController: WelcomePage())
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    func switchToHomePageVC() {
        guard let window = window else { return }
        window.rootViewController = UINavigationController(rootViewController: MainTabbar())
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
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

