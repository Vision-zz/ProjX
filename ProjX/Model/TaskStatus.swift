//
//  TaskStatus.swift
//  ProjX
//
//  Created by Sathya on 23/03/23.
//

import Foundation

enum TaskStatus: Int16, Codable {
    case unknown = 0
    case inProgress = 1
    case complete = 2
}
