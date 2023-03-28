//
//  User+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//
//

import Foundation
import CoreData
import UIKit

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
        set {
            guard let teamID = newValue?.teamID, teamID != selectedTeamID else {
                return
            }
            selectedTeamID = teamID
        }
    }

    var roleInCurrentTeam: UserRole {
        get {
            guard let selectedTeam = selectedTeam else {
                return .none
            }
            return roleIn(team: selectedTeam)
        }
    }

    func roleIn(team: Team) -> UserRole {
        if team.teamOwnerID! == userID {
            return .owner
        } else if team.teamAdmins.contains(where: { $0.userID! == userID }) {
            return .admin
        } else if team.teamMembers.contains(where: { $0.userID! == userID }) {
            return .member
        } else {
            return .none
        }
    }

    var userProfileImage: UIImage {
        get {
            guard let profileImage = profileImage else {
                var sfSymbolPrefix = "questionmark"
                if let userName = name, (!userName.isEmpty && String(userName.first!).firstMatch(of: /[^a-zA-Z]/) == nil) {
                    sfSymbolPrefix = String(userName.first!)
                }
                return UIImage(systemName: "\(sfSymbolPrefix.lowercased()).square.fill")!
            }
            return UIImage(data: profileImage) ?? UIImage(systemName: "questionmark.square.fill")!
        }
        set {
            profileImage = newValue.pngData()
        }
    }

    func isOwner(_ team: Team) -> Bool {
        guard let _ = team.teamOwnerID else { return false }
        return roleIn(team: team) == .owner
    }

    func isInTeam(_ team: Team) -> Bool {
        guard let userTeams = userTeams else { return false }
        return (userTeams.first(where: { $0 == team.teamID }) != nil)
    }

    func join(team: Team) {
        guard !isInTeam(team) else { return }
        self.teams.append(team)
        team.teamMembers.append(self)
        DataManager.shared.saveContext()
    }

    func leave(team: Team) {
        guard !isOwner(team) else { return }
        guard isInTeam(team) else { return }
        if userTeams == nil {
            userTeams = []
        }
        let index = userTeams!.firstIndex(where: { $0 == team.teamID })
        guard let index = index else { return }
        userTeams!.remove(at: index)
        if selectedTeamID != nil && selectedTeamID == team.teamID {
            selectedTeamID = nil
        }

        switch roleIn(team: team) {
            case .none, .owner:
                return
            case .admin:
                guard let teamAdminsID = team.teamAdminsID else { return }
                let indexInTeam = teamAdminsID.firstIndex(where: { $0 == userID })
                guard let indexInTeam = indexInTeam else { return }
                team.teamAdmins.remove(at: indexInTeam)
            case .member:
                guard let teamMembersID = team.teamMembersID else { return }
                let indexInTeam = teamMembersID.firstIndex(where: { $0 == userID })
                guard let indexInTeam = indexInTeam else { return }
                team.teamMembers.remove(at: indexInTeam)
        }

        DataManager.shared.saveContext()
    }

}
