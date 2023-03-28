//
//  TeamDelegates.swift
//  ProjX
//
//  Created by Sathya on 24/03/23.
//

import Foundation

protocol JoinTeamDelegate: AnyObject {
    func joined(_ team: Team)
}

protocol CreateTeamDelegate: AnyObject {
    func created(_ team: Team)
}

protocol TeamExitDelegate: AnyObject {
    func teamExited()
}

protocol TeamExitButtonDelegate: AnyObject {
    func teamExitButtonPressed()
}
