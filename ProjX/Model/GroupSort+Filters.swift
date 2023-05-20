//
//  Filters.swift
//  ProjX
//
//  Created by Sathya on 09/05/23.
//

import Foundation

enum GroupByOption: Codable {
    case priority(SortLevel, PriorityGroupSortOptions)
    case createdTime(SortLevel, CreatedTimeGroupSortOptions)
    case estimatedTime(SortLevel, EstimatedTimeGroupSortOptions)
    
    var toFullString: String {
        get {
            switch self {
                case .priority(_, _):
                    return "Priority"
                case .createdTime(_, _):
                    return "Created Time"
                case .estimatedTime(_, _):
                    return "Estimated Time"
            }
        }
    }
    
    var toString: String {
        get {
            switch self {
                case .priority(let level, _):
                    return level == .highToLow ? "High to Low" : "Low to High"
                case .createdTime(let level, _):
                    return level == .highToLow ? "Newest First" : "Oldest First"
                case .estimatedTime(let level, _):
                    return level == .highToLow ? "Farthest First" : "Closest First"
            }
        }
    }
    
    static func defaultGroupByOption() -> GroupByOption {
        return .priority(.highToLow, .estimatedTime(.highToLow))
    }
    
    static func isDefaultGroupByOption(_ option: GroupByOption) -> Bool {
        if case let (GroupByOption.priority(firstLeft, secondLeft), GroupByOption.priority(firstRight, secondRight)) = (defaultGroupByOption(), option) {
            if case let (PriorityGroupSortOptions.estimatedTime(leftOption), PriorityGroupSortOptions.estimatedTime(rightOption)) = (secondLeft, secondRight) {
                if firstLeft == firstRight && leftOption == rightOption {
                    return true
                }
            }
        }
        return false
    }
    
}

enum PriorityGroupSortOptions: Codable {
    case createdTime(SortLevel)
    case estimatedTime(SortLevel)
    
    var sortLevelString: String {
        switch self {
            case .createdTime(let level):
                return level == .highToLow ? "Newest First" : "Oldest First"
            case .estimatedTime(let level):
                return level == .highToLow ? "Farthest First" : "Closest First"
        }
    }
    
    var toString: String {
        switch self {
            case .createdTime(_):
                return "Created Time"
            case .estimatedTime(_):
                return "Estimated Time"
        }
    }
}

enum CreatedTimeGroupSortOptions: Codable {
    case priority(SortLevel)
    case estimatedTime(SortLevel)
    
    var sortLevelString: String {
        switch self {
            case .priority(let level):
                return level == .highToLow ? "High to Low" : "Low to High"
            case .estimatedTime(let level):
                return level == .highToLow ? "Farthest First" : "Closest First"
        }
    }
    
    var toString: String {
        switch self {
            case .priority(_):
                return "Priority"
            case .estimatedTime(_):
                return "Estimated Time"
        }
    }
}

enum EstimatedTimeGroupSortOptions: Codable {
    case priority(SortLevel)
    case createdTime(SortLevel)
    
    var sortLevelString: String {
        switch self {
            case .priority(let level):
                return level == .highToLow ? "High to Low" : "Low to High"
            case .createdTime(let level):
                return level == .highToLow ? "Newest First" : "Oldest First"
        }
    }
    
    var toString: String {
        switch self {
            case .priority(_):
                return "Priority"
            case .createdTime(_):
                return "Created Time"
        }
    }
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
    
    func defaultFilterOption(of user: User) -> Filters {
        let filter = Filters(assignedTo: user.userID)
        return filter
    }
    
    func isDefaultFilterOption(of user: User) -> Bool {
        guard let assignedTo = self.assignedTo, assignedTo == user.userID!
                && self.createdBy == nil
                && self.createdBetween == nil
                && self.etaBetween == nil
                && self.taskStatus == .inProgress
        else { return false }
        return true
    }
    
}
