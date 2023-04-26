//
//  User+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var emailID: String?
    @NSManaged public var name: String?
    @NSManaged public var notificationUpdates: [NotificationUpdate]?
    @NSManaged public var password: String?
    @NSManaged public var userID: UUID?
    @NSManaged public var username: String?
    @NSManaged public var userTeams: [UUID]?
    @NSManaged public var selectedTeamID: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var passLastUpdate: Date?

}

extension User : Identifiable {

}
