//
//  Team+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//
//

import Foundation
import CoreData
import UIKit

public class Team: NSManagedObject {

    var tasks: [TaskItem] {
        get {
            let fetchedData = try? DataManager.shared.context.fetch(TaskItem.fetchRequest())
            guard let tasksID = tasksID, let fetchedData = fetchedData else {
                return []
            }
            let tasksArr = fetchedData.filter { task in
                task.taskID != nil ? tasksID.contains(task.taskID!) : false
            }
            return tasksArr
        }
        set {
            var arr = [UUID]()
            newValue.forEach { value in
                if let taskID = value.taskID {
                    arr.append(taskID)
                }
            }
            tasksID = arr
        }
    }

    var teamOwner: User? {
        get {
            let fetchedData = try? DataManager.shared.context.fetch(User.fetchRequest())
            guard let teamOwnerID = teamOwnerID, let fetchedData = fetchedData else {
                return nil
            }
            let user = fetchedData.first { $0.userID == teamOwnerID }
            return user
        }
        set {
            teamOwnerID = newValue?.userID
        }
    }

    var teamAdmins: [User] {
        get {
            let fetchedData = try? DataManager.shared.context.fetch(User.fetchRequest())
            guard let teamAdminsID = teamAdminsID, let fetchedData = fetchedData else {
                return []
            }
            let adminArr = fetchedData.filter { admin in
                admin.userID != nil ? teamAdminsID.contains(admin.userID!) : false
            }
            return adminArr
        }
        set {
            var arr = [UUID]()
            newValue.forEach { value in
                if let adminID = value.userID {
                    arr.append(adminID)
                }
            }
            teamAdminsID = arr
        }
    }

    var teamMembers: [User] {
        get {
            let fetchedData = try? DataManager.shared.context.fetch(User.fetchRequest())
            guard let teamMembersID = teamMembersID, let fetchedData = fetchedData else {
                return []
            }
            let memberArr = fetchedData.filter { member in
                member.userID != nil ? teamMembersID.contains(member.userID!) : false
            }
            return memberArr
        }
        set {
            var arr = [UUID]()
            newValue.forEach { value in
                if let memberID = value.userID {
                    arr.append(memberID)
                }
            }
            teamMembersID = arr
        }
    }

    var allTeamMembers: [User] {
        get {
            return [teamOwner!] + teamAdmins + teamMembers
        }
    }

    var isSelected: Bool {
        return SessionManager.shared.signedInUser?.selectedTeamID != nil && SessionManager.shared.signedInUser!.selectedTeamID == teamID
    }

    func hasTeamIcon() -> Bool {
        guard let name = teamID?.uuidString else { return false }
        return DataManager.shared.imageExists(with: name)
    }

    func getTeamIcon(reduceTo size: CGSize? = nil) -> UIImage {
        let defaultImage = Util.generateInitialImage(from: teamName!) ?? UIImage(systemName: "questionmark.square.fill")!
        guard let name = teamID?.uuidString else { return defaultImage }
        let image = DataManager.shared.loadImage(with: name)

        guard let size = size else {
            return image ?? defaultImage
        }

        guard let image = image,
              let data = image.pngData(),
              let downsampledImage = Util.downsampleImage(from: data, to: size)
        else {
            return defaultImage
        }

        return downsampledImage
    }

    func setTeamIcon(image: UIImage) {
        guard let name = teamID?.uuidString else { return }
        DataManager.shared.saveImage(image, with: name)
    }

    func removeTeamIcon() {
        guard let name = teamID?.uuidString else { return }
        DataManager.shared.removeImage(with: name)
    }

    func makeUserAdmin(_ user: User) {
        guard let userID = user.userID, userID != teamOwnerID, !teamAdmins.contains(where: { $0.userID == userID }) else { return }
        teamAdmins.append(user)

        let teamMemberIndex = teamMembersID?.firstIndex(where: { $0 == userID })
        if let teamMemberIndex = teamMemberIndex {
            teamMembersID?.remove(at: teamMemberIndex)
        }

        DataManager.shared.saveContext()
    }

    func makeUserMember(_ user: User) {
        guard let userID = user.userID, userID != teamOwnerID, !teamMembers.contains(where: { $0.userID == userID }) else { return }
        teamMembers.append(user)

        let teamAdminIndex = teamAdminsID?.firstIndex(where: { $0 == userID })
        if let teamAdminIndex = teamAdminIndex {
            teamAdminsID?.remove(at: teamAdminIndex)
        }
        DataManager.shared.saveContext()
    }

    func regeneratePasscode() {
        let allTeamJoinCodes = DataManager.shared.getAllTeams().map({ $0.teamJoinPasscode })
        var newCode = Util.generateAlphanumericString(of: 15)
        while allTeamJoinCodes.contains(newCode) {
            newCode = Util.generateAlphanumericString(of: 12)
        }
        teamJoinPasscode = newCode
        DataManager.shared.saveContext()
    }

}
