//
//  SigninToSignupSwitchDelegate.swift
//  ProjX
//
//  Created by Sathya on 17/03/23.
//

import Foundation

protocol SignInDelegate: AnyObject {
    func signUpSwitchButtonPressed()
    func successfulLogin()
}

protocol SignUpDelegate: AnyObject {
    func signInSwitchButtonPressed()
    func successfulRegister(user: User)
}
