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
        newUser.profileImage = profileImage?.jpegData(compressionQuality: 1)
        newUser.userTeams = []
        newUser.userID = UUID()
        saveContext()

        return .success(newUser)
    }

    func createTeam(name: String, image: UIImage?) -> Team {
        let newTeam = Team(context: context)
        newTeam.teamID = UUID()
        newTeam.teamCreatedAt = Date()
        newTeam.teamName = name
        newTeam.teamOwnerID = SessionManager.shared.signedInUser!.userID
        newTeam.teamJoinPasscode = Util.generateAlphanumericString(of: 15)
        newTeam.categories = []
        newTeam.teamMembersID = []
        newTeam.teamAdminsID = []
        newTeam.tasksID = []

        SessionManager.shared.signedInUser?.teams.append(newTeam)

        saveContext()
        return newTeam
    }

    func saveImage(_ image: UIImage, with name: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = documentsDirectory.appendingPathComponent(name)

        guard let data = image.pngData(),
              let compressedData = Util.downsampleImage(from: data, to: CGSize(width: 256, height: 256))?.pngData()
        else { return }



        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                Logger.log("Removed old image at \(fileURL.path)")
                print("Removed old image")
            } catch let removeError {
                Logger.log("Couldn't remove file at \(fileURL.path)", removeError)
            }

        }

        do {
            try compressedData.write(to: fileURL)
            Logger.log("Successfully saved image to \(fileURL.path)")
        } catch let error {
            Logger.log("Error saving file with error", error)
        }
    }

    func removeImage(with name: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = documentsDirectory.appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                Logger.log("Removed old image at \(fileURL.path)")
                print("Removed old image")
            } catch let removeError {
                Logger.log("Couldn't remove file at \(fileURL.path)", removeError)
            }

        }
    }

    func imageExists(with name: String) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let fileURL = documentsDirectory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func loadImage(with name: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }

}
