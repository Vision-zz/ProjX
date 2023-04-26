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

    func getUserProfileIcon(reduceTo size: CGSize? = nil) -> UIImage {
        let defaultImage = Util.generateInitialImage(from: name!) ?? UIImage(systemName: "questionmark.square.fill")!
        guard let name = userID?.uuidString else { return defaultImage }
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

    func hasUserProfileIcon() -> Bool {
        guard let name = userID?.uuidString else { return false }
        return DataManager.shared.imageExists(with: name)
    }

    func setUserProfileIcon(image: UIImage) {
        guard let name = userID?.uuidString else { return }
        DataManager.shared.saveImage(image, with: name)
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
        if selectedTeam == nil {
            selectedTeam = team
        }
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

        let indexInAdminArr = team.teamAdminsID?.firstIndex(where: { $0 == userID })
        let indexInMemberArr = team.teamMembersID?.firstIndex(where: { $0 == userID })

        if indexInAdminArr != nil {
            team.teamAdminsID?.remove(at: indexInAdminArr!)
            for task in team.tasks {
                if task.createdBy != nil && task.createdBy == userID {
                    if roleIn(team: team) == .member {
                        DataManager.shared.context.delete(task)
                        continue
                    } else {
                        task.createdBy = team.teamOwnerID
                        continue
                    }
                }
                if task.assignedTo != nil && task.assignedTo == userID! {
                    task.assignedTo = team.allTeamMembers.randomElement()!.userID
                }
            }
        } else if indexInMemberArr != nil {
            team.teamMembersID?.remove(at: indexInMemberArr!)
        }

        DataManager.shared.saveContext()
    }

}
