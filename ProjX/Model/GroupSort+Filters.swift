//
//  Filters.swift
//  ProjX
//
//  Created by Sathya on 09/05/23.
//

import Foundation

enum GroupByOption: Codable {
    case priority(SortLevel, PriorityGroupSortOptions)
    case createdAt(TimeBasedGroupSortOptions)
    case eta(TimeBasedGroupSortOptions)
}

enum PriorityGroupSortOptions: Codable {
    case none
    case createdAt(SortLevel)
    case eta(SortLevel)
}

enum TimeBasedGroupSortOptions: Codable {
    case none
    case priority(SortLevel)
}

enum SortLevel: Codable {
    case lowToHigh
    case highToLow
}

class DatesBetween: Codable {
    var start: Date
    var end: Date
    
    init() {
        self.start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        self.end = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

class Filters: Codable {
    var assignedTo: UUID? = nil
    var createdBy: UUID? = nil
    var taskStatus: TaskStatus = .inProgress
    var createdBetween: DatesBetween? = nil
    var etaBetween: DatesBetween? = nil
    
    var totalSelectedFilters: Int {
        get {
            var nonNilPropertyCount = 1
            if assignedTo != nil { nonNilPropertyCount += 1 }
            if createdBy != nil { nonNilPropertyCount += 1}
            if createdBetween != nil { nonNilPropertyCount += 1}
            if etaBetween != nil { nonNilPropertyCount += 1}
            return nonNilPropertyCount
        }
    }
    
    init(assignedTo: UUID? = nil) {
        self.assignedTo = assignedTo
    }
}
