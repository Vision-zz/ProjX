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

protocol CreateEditTeamDelegate: AnyObject {
    func changesSaved(_ team: Team)
}

protocol TeamExitDelegate: AnyObject {
    func teamExited()
}

protocol TeamOptionsDelegate: AnyObject {
    func teamSelectButtonPressed()
    func teamEditButtonPressed()
    func teamExitButtonPressed()
}
