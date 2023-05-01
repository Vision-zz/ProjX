//
//  ProfileUpdateDelegate.swift
//  ProjX
//
//  Created by Sathya on 27/04/23.
//

import Foundation

protocol ProfileUpdateDelegate: AnyObject {
    func profileUpdated()
}

protocol PasswordUpdateDelegate: AnyObject {
    func passwordChanged(to newPassword: String)
}
