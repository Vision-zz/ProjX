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

    var teamIconImage: UIImage {
        get {
            guard let teamIcon = teamIcon else {
                var sfSymbolPrefix = "questionmark"
                if let teamName = teamName, (!teamName.isEmpty && String(teamName.first!).firstMatch(of: /[^a-zA-Z]/) == nil) {
                    sfSymbolPrefix = String(teamName.first!)
                }
                return UIImage(systemName: "\(sfSymbolPrefix.lowercased()).square.fill")!
            }
            return UIImage(data: teamIcon) ?? UIImage(systemName: "questionmark.square.fill")!
        }
    }

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

    func regeneratePasscode() {
        let allTeamJoinCodes = DataManager.shared.getAllTeams().map({ $0.teamJoinPasscode })
        var newCode = Util.generateAlphanumericString(of: 15)
        while allTeamJoinCodes.contains(newCode) {
            newCode = Util.generateAlphanumericString(of: 12)
        }
        teamJoinPasscode = newCode
        DataManager.shared.saveContext()
    }

    func delete() {
        DataManager.shared.context.delete(self)
        DataManager.shared.saveContext()
    }

}
