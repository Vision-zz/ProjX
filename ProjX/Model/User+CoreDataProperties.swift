//
//  User+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 17/05/23.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var emailID: String?
    @NSManaged public var name: String?
    @NSManaged public var notificationUpdates: [NotificationUpdate]?
    @NSManaged public var passLastUpdate: Date?
    @NSManaged public var password: String?
    @NSManaged public var selectedTeamID: UUID?
    @NSManaged public var userID: UUID?
    @NSManaged public var username: String?
    @NSManaged public var userTeams: [UUID]?
    @NSManaged public var doNotShowAgain: Bool
    @NSManaged public var taskFilterSettings: FilterOptions?

}

extension User : Identifiable {

}
