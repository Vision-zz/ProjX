//
//  SignupStatus.swift
//  ProjX
//
//  Created by Sathya on 27/03/23.
//

import Foundation

enum SignupFailure: String {
    case usernameNotAvailable = "Username is not available"
}

enum SignupStatus {
    case success(User)
    case failure(SignupFailure)
}
