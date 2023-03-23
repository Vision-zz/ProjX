//
//  SessionManager.swift
//  ProjX
//
//  Created by Sathya on 22/03/23.
//

import Foundation
import UIKit

class SessionManager {

    enum AuthenticationFailure {
        case userNotFound, invalidPassowrd
    }

    enum AuthenticationStatus {
        case success(User)
        case failure(AuthenticationFailure)
    }

    static let shared: SessionManager = SessionManager()

    lazy var signedInUser: User? = nil

    func authenticate(username: String, password: String) -> AuthenticationStatus {
        let users = DataManager.shared.getAllUsers()
        guard users.count > 0, let user = users.first(where: { $0.username == username }) else {
            return AuthenticationStatus.failure(.userNotFound)
        }
        guard user.password != nil, user.password == password else {
            return AuthenticationStatus.failure(.invalidPassowrd)
        }
        UserDefaults.standard.set(user.userID!.uuidString, forKey: GlobalConstants.UserDefaultsKey.currentLoggedInUserID)
        signedInUser = user
        return AuthenticationStatus.success(user)
    }

    func logout() {
        signedInUser = nil
        UserDefaults.standard.set(nil, forKey: GlobalConstants.UserDefaultsKey.currentLoggedInUserID)
        SceneDelegate.shared?.switchToWelcomePageVC()
    }

}
