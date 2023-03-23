//
//  User+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {
    public override var description: String {
        return "User"
    }

    var teams: [Team] {
        get {
            let fetchedData = try? DataManager.shared.context.fetch(Team.fetchRequest())
            guard let userTeams = userTeams, let fetchedData = fetchedData else {
                return []
            }
            let teamArr = fetchedData.filter { team in
                userTeams.contains { $0 == team.teamID }
            }
            return teamArr
        }
        set {
            var arr = [UUID]()
            newValue.forEach { value in
                if let teamID = value.teamID {
                    arr.append(teamID)
                }
            }
            userTeams = arr
        }
    }

    var selectedTeam: Team? {
        get {
            teams.first(where: { $0.teamID != nil && $0.teamID! == selectedTeamID })
        }
    }

    var roleInCurrentTeam: UserRole {
        get {
            guard let selectedTeam = selectedTeam else {
                return .none
            }
            if selectedTeam.teamOwnerID! == userID {
                return .owner
            } else if selectedTeam.teamAdmins.contains(where: { $0.userID! == userID }) {
                return .admin
            } else if selectedTeam.teamMembers.contains(where: { $0.userID! == userID }) {
                return .member
            } else {
                return .none
            }
        }
    }

}
