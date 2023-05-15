//
//  NotificationUpdate+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 09/05/23.
//
//

import Foundation
import CoreData


extension NotificationUpdate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationUpdate> {
        return NSFetchRequest<NotificationUpdate>(entityName: "NotificationUpdate")
    }

    @NSManaged public var isRead: Bool
    @NSManaged public var notificationMessage: String?

}

extension NotificationUpdate : Identifiable {

}
