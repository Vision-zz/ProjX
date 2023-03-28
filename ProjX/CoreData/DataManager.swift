//
//  DataRouter.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import CoreData
import UIKit

class DataManager {

    static let shared: DataManager = DataManager()

    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let saveContext: () -> Void = (UIApplication.shared.delegate as! AppDelegate).saveContext

    private init() {}

    func getAllUsers() -> [User] {
        return (try? context.fetch(User.fetchRequest())) ?? []
    }

    func getAllTeams() -> [Team] {
        return (try? context.fetch(Team.fetchRequest())) ?? []
    }

    func getUserMatching(_ predicate: (User) -> Bool) -> User? {
        let users = getAllUsers()
        for user in users {
            if predicate(user) {
                return user
            }
        }
        return nil
    }

    func getTeamMatching(_ predicate: (Team) -> Bool) -> Team? {
        let teams = getAllTeams()
        for team in teams {
            if predicate(team) {
                return team
            }
        }
        return nil
    }

    func createUser(username: String, password: String, name: String, emailID: String, profileImage: UIImage? = nil) -> SignupStatus {
        let user = getUserMatching({ $0.username != nil && $0.username == username })
        guard user == nil else {
            return .failure(.usernameNotAvailable)
        }

        let newUser = User(context: context)
        newUser.username = username
        newUser.password = password
        newUser.name = name
        newUser.emailID = emailID
        if profileImage != nil {
            newUser.userProfileImage = profileImage!
        }
        newUser.userTeams = []
        newUser.userID = UUID()
        saveContext()

        return .success(newUser)
    }

}
