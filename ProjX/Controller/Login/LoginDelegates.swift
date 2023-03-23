//
//  SigninToSignupSwitchDelegate.swift
//  ProjX
//
//  Created by Sathya on 17/03/23.
//

import Foundation

protocol SignInDelegate {
    func signUpSwitchButtonPressed()
    func successfulLogin()
}

protocol SignUpDelegate {
    func signInSwitchButtonPressed()
    func successfulRegister()
}
