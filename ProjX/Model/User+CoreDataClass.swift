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

}
