//
//  StatusUpdate.swift
//  Enceladus
//
//  Created by Sathya on 20/03/23.
//

import Foundation

@objc public class StatusUpdate: NSObject, NSSecureCoding {
    let subject: String
    let statusDescription: String
    let createdAt: Date?

    init(subject: String, description: String, createdAt: Date) {
        self.subject = subject
        self.statusDescription = description
        self.createdAt = createdAt
    }

    public required init?(coder: NSCoder) {
        subject = coder.decodeObject(forKey: "subject") as? String ?? "-"
        statusDescription = coder.decodeObject(forKey: "statusDescription") as? String ?? "-"
        createdAt = coder.decodeObject(forKey: "createdAt") as? Date
    }

    public func encode(with coder: NSCoder) {
        coder.encode(subject, forKey: "subject")
        coder.encode(statusDescription, forKey: "statusDescription")
        coder.encode(createdAt, forKey: "createdAt")
    }

    public static var supportsSecureCoding: Bool {
        true
    }
}
