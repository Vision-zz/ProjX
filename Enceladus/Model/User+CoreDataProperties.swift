//
//  User+CoreDataProperties.swift
//  Enceladus
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
    @NSManaged public var password: String?
    @NSManaged public var profileImage: Data?
    @NSManaged public var userID: UUID?
    @NSManaged public var username: String?
    @NSManaged public var userTeams: [UUID]?

}

extension User : Identifiable {

}
