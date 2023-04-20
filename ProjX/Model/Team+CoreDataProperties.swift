//
//  Team+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var tasksID: [UUID]?
    @NSManaged public var teamAdminsID: [UUID]?
    @NSManaged public var teamID: UUID?
    @NSManaged public var teamMembersID: [UUID]?
    @NSManaged public var teamName: String?
    @NSManaged public var teamOwnerID: UUID?
    @NSManaged public var teamJoinPasscode: String?
    @NSManaged public var teamCreatedAt: Date?

}

extension Team : Identifiable {

}
