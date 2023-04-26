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

    func getUserMatching(_ predicate: (User) -> Bool) -> User? {
        let users = getAllUsers()
        for user in users {
            if predicate(user) {
                return user
            }
        }
        return nil
    }

    func getAllTeams() -> [Team] {
        return (try? context.fetch(Team.fetchRequest())) ?? []
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

    func getAllTasks(for team: Team) -> [TaskItem] {
        return (try? context.fetch(TaskItem.fetchRequest())) ?? []
    }

    func getTasks(for team: Team, matching predicate: (TaskItem) -> Bool) -> [TaskItem] {
        return getAllTasks(for: team).filter(predicate)
    }

    @discardableResult
    func createUser(username: String, password: String, name: String, emailID: String, profileImage: UIImage? = nil) -> SignupStatus {
        let user = getUserMatching({ $0.username != nil && $0.username == username })
        guard user == nil else {
            return .failure(.usernameNotAvailable)
        }

        let newUser = User(context: context)
        let userID = UUID()
        newUser.createdAt = Date()
        newUser.passLastUpdate = Date()
        newUser.username = username
        newUser.password = password
        newUser.name = name
        newUser.emailID = emailID
        newUser.userTeams = []
        newUser.userID = userID
        newUser.notificationUpdates = []

        if profileImage != nil {
            DataManager.shared.saveImage(profileImage!, with: userID.uuidString)
        }

        saveContext()

        return .success(newUser)
    }

    func deleteUser(username: String) {
        let user = getUserMatching({ $0.username != nil && $0.username == username })
        guard let user = user else { return }

        for team in user.teams {
            if team.teamOwnerID! == user.userID {
                if let admin = team.teamAdmins.first {
                    team.teamOwnerID = admin.userID
                } else {
                    context.delete(team)
                    continue
                }
            }
            for task in team.tasks {
                if task.createdBy != nil && task.createdBy == user.userID {
                    if task.assignedTo != nil && task.assignedTo == user.userID! {
                        context.delete(task)
                        continue
                    }
                    if user.roleIn(team: team) == .member {
                        context.delete(task)
                        continue
                    } else {
                        task.createdBy = team.teamOwnerID
                        continue
                    }
                }
                if task.assignedTo != nil && task.assignedTo == user.userID! {
                    task.assignedTo = team.allTeamMembers.randomElement()!.userID
                }
            }
        }

        context.delete(user)
        saveContext()
        SessionManager.shared.logout()
    }

    @discardableResult
    func createTeam(name: String, createdBy: User, image: UIImage?) -> Team {
        let newTeam = Team(context: context)
        newTeam.teamID = UUID()
        newTeam.teamCreatedAt = Date()
        newTeam.teamName = name
        if image != nil {
            newTeam.setTeamIcon(image: image!)
        }
        newTeam.teamOwnerID = createdBy.userID
        newTeam.teamJoinPasscode = Util.generateAlphanumericString(of: 15)
        newTeam.teamMembersID = []
        newTeam.teamAdminsID = []
        newTeam.tasksID = []

        createdBy.teams.append(newTeam)
        if createdBy.selectedTeam == nil {
            SessionManager.shared.changeSelectedTeam(of: createdBy, to: newTeam)
        }
        saveContext()
        return newTeam
    }

    @discardableResult
    func createTask(title: String, description: String, deadLine: Date, assignedTo: User, priority: TaskPriority) -> TaskItem {
        let task = TaskItem(context: context)
        task.taskID = UUID()
        task.title = title
        task.taskDescription = description
        task.deadline = deadLine
        task.assignedToUser = assignedTo
        task.priority = priority.rawValue
        task.createdAt = Date()
        task.createdByUser = SessionManager.shared.signedInUser!
        task.taskStatus = .incomplete
        task.statusUpdates = []
        SessionManager.shared.signedInUser?.selectedTeam?.tasksID?.append(task.taskID!)

        saveContext()
        return task
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
                print("Removed old image at \(fileURL.path)")
            } catch let removeError {
                print("Couldn't remove file at \(fileURL.path)", removeError)
            }
        }

        do {
            try compressedData.write(to: fileURL)
            print("Successfully saved image to \(fileURL.path)")
        } catch let error {
            print("Error saving file with error", error)
        }
    }

    func removeImage(with name: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent(name)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image at \(fileURL.path)")
            } catch let removeError {
                print("Couldn't remove file at \(fileURL.path)", removeError)
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

    func setSelectedTheme(_ theme: GlobalConstants.Device.SelectedTheme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: GlobalConstants.UserDefaultsKey.selectedTheme)
        GlobalConstants.StructureDelegates.sceneDelegate?.changeUserInterfaceStyle()
    }

    func setSelectedAccentColor(_ accentColor: GlobalConstants.Colors.AccentColor) {
        UserDefaults.standard.set(accentColor.rawValue, forKey: GlobalConstants.UserDefaultsKey.selectedAccentColor)
        print("Set to user defaults")
        GlobalConstants.StructureDelegates.appDelegate?.updateTheme()
        print("Finish update theme")
    }

}
