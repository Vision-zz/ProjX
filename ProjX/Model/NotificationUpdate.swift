//
//  NotificationUpdate.swift
//  ProjX
//
//  Created by Sathya on 06/04/23.
//

import Foundation

public class NotificationUpdate: NSObject, NSSecureCoding {

    let notificationMessage: String
    private(set) var isRead: Bool

    init(message: String) {
        self.notificationMessage = message
        isRead = false
    }

    func markAsRead() {
        guard isRead == false else { return }
        isRead = true
    }

    func markAsUnread() {
        guard isRead == true else { return }
        isRead = false
    }

    public required init?(coder: NSCoder) {
        notificationMessage = coder.decodeObject(forKey: "notificationMessage") as? String ?? "-"
        isRead = coder.decodeBool(forKey: "isRead")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(notificationMessage, forKey: "notificationMessage")
        coder.encode(isRead, forKey: "isRead")
    }

    public static var supportsSecureCoding: Bool {
        true
    }

}
