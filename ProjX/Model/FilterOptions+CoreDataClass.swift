//
//  FilterOptions+CoreDataClass.swift
//  ProjX
//
//  Created by Sathya on 09/05/23.
//
//

import Foundation
import CoreData


public class FilterOptions: NSManagedObject {
    var groupAndSortBy: GroupByOption {
        get {
            guard let groupAndSortByString = groupAndSortByString,
                  let obj = try? JSONDecoder().decode(GroupByOption.self, from: Data(groupAndSortByString.utf8))
            else {
                return .priority(.highToLow, .createdTime(.highToLow))
            }
            return obj
        }
        set {
            let jsonData = try? JSONEncoder().encode(newValue)
            if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
                groupAndSortByString = jsonString
                return
            }
            groupAndSortByString = nil
        }
    }
    
    var filters: Filters {
        get {
            guard let filtersString = filtersString,
                  let obj = try? JSONDecoder().decode(Filters.self, from: Data(filtersString.utf8))
            else {
                return Filters()
            }
            return obj
        }
        set {
            let jsonData = try? JSONEncoder().encode(newValue)
            if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
                filtersString = jsonString
                return
            }
            filtersString = nil
        }
    }
    
 
    func groupAndFilter(_ tasks: [TaskItem]) -> [TasksVC.SectionData]? {
        var data = tasks
        
        data = tasks.filter({ item in
            var filtersSatisfied = 0
            
            if let assignedTo = filters.assignedTo, let itemAssignedTo = item.assignedTo, assignedTo == itemAssignedTo {
                filtersSatisfied += 1
            }
            
            if let createdBy = filters.createdBy, let itemCreatedBy = item.createdBy, createdBy == itemCreatedBy {
                filtersSatisfied += 1
            }
            
            if filters.taskStatus == .unknown || (filters.taskStatus != .unknown && filters.taskStatus == item.taskStatus) {
                filtersSatisfied += 1
            }
            
            if let createdBetween = filters.createdBetween, let createdAt = item.createdAt, createdAt >= createdBetween.start && createdAt <= createdBetween.end {
                filtersSatisfied += 1
            }
            
            if let etaBetween = filters.etaBetween, let eta = item.deadline, eta >= etaBetween.start && eta <= etaBetween.end {
                filtersSatisfied += 1
            }
            
            return filtersSatisfied == filters.totalSelectedFilters
        })
        
        
        var datasource = [TasksVC.SectionData]()
        
        switch groupAndSortBy {
            case .priority(let level, let sortOption):
                datasource = groupByPriority(tasks: data, sortLevel: level)
                switch sortOption {
                    case .createdTime(let inlineLevel):
                        datasource = sortDataByDate(datasource: datasource, createdAt: true, sortLevel: inlineLevel)
                    case .estimatedTime(let inlineLevel):
                        datasource = sortDataByDate(datasource: datasource, createdAt: false, sortLevel: inlineLevel)
                }
            case .createdTime(let level, let sortOption):
                datasource = groupByDate(tasks: data, createdAt: true, sortLevel: level)
                switch sortOption {
                    case .priority(let inlineLevel):
                        datasource = sortDataByPriority(datasource: datasource, sortLevel: inlineLevel)
                    default:
                        break
                }
            case .estimatedTime(let level, let sortOption):
                datasource = groupByDate(tasks: data, createdAt: false, sortLevel: level)
                switch sortOption {
                    case .priority(let inlineLevel):
                        datasource = sortDataByPriority(datasource: datasource, sortLevel: inlineLevel)
                    default:
                        break
                }
        }
        return datasource
    }
    
    private func sortDataByPriority(datasource: [TasksVC.SectionData],  sortLevel: SortLevel) -> [TasksVC.SectionData] {
        var data = datasource
        for i in 0..<data.count {
            if sortLevel == .highToLow {
                data[i].rows.sort { $0.priority > $1.priority }
            } else {
                data[i].rows.sort { $0.priority < $1.priority }
            }
        }
        return data
    }
    
    private func sortDataByDate(datasource: [TasksVC.SectionData], createdAt: Bool, sortLevel: SortLevel) -> [TasksVC.SectionData] {
        var data = datasource
        for i in 0..<data.count {
            if createdAt {
                if sortLevel == .highToLow {
                    data[i].rows = data[i].rows.sorted(by: { $0.createdAt!.timeIntervalSince1970 > $1.createdAt!.timeIntervalSince1970 })
                } else {
                    data[i].rows = data[i].rows.sorted(by: { $0.createdAt!.timeIntervalSince1970 < $1.createdAt!.timeIntervalSince1970 })
                }
            } else {
                if sortLevel == .highToLow {
                    data[i].rows = data[i].rows.sorted(by: { $0.deadline!.timeIntervalSince1970 > $1.deadline!.timeIntervalSince1970 })
                } else {
                    data[i].rows = data[i].rows.sorted(by: { $0.deadline!.timeIntervalSince1970 < $1.deadline!.timeIntervalSince1970 })
                }
            }
        }
        return data
    }
    
    private func groupByPriority(tasks: [TaskItem], sortLevel: SortLevel) -> [TasksVC.SectionData] {
        let tasksByPriority = Dictionary(grouping: tasks, by: { $0.taskPriority })
        
        let priorityDict = [
            "Low Priority": 0,
            "Medium Priority": 1,
            "High Priority": 2
        ]
        
        let option =  tasksByPriority.map { (priority, objects) -> TasksVC.SectionData in
            let sectionName: String
            switch priority {
                case .high:
                    sectionName = "High Priority"
                case .medium:
                    sectionName = "Medium Priority"
                case .low:
                    sectionName = "Low Priority"
            }
            return TasksVC.SectionData(sectionName: sectionName, rows: objects)
        }
            .filter { !$0.rows.isEmpty }
            .sorted(by: {
                switch sortLevel {
                    case .highToLow:
                        return priorityDict[$0.sectionName]! > priorityDict[$1.sectionName]!
                    case .lowToHigh:
                        return priorityDict[$0.sectionName]! < priorityDict[$1.sectionName]!
                }
            })
        
        
        return option
        
    }
    
    private func groupByDate(tasks: [TaskItem], createdAt: Bool, sortLevel: SortLevel) -> [TasksVC.SectionData] {
        let currentDate = Date()
        
        struct Key: Hashable {
            var sectionName: String
            var sectionDate: Date
        }
        
        let date = Date()
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MMMM yyyy"
        let yearString = yearFormatter.string(from: Date())

        let objectsByMonth = Dictionary(grouping: tasks) { object -> Key in
            let objectDate = createdAt ? object.createdAt : object.deadline
            if Calendar.current.isDate(objectDate!, equalTo: currentDate, toGranularity: .day) {
                return Key(sectionName: "Today", sectionDate: date)
            } else if Calendar.current.isDate(objectDate!, equalTo: currentDate, toGranularity: .year) {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM"
                let monthString =  monthFormatter.string(from: objectDate!)
                return Key(sectionName: monthString, sectionDate: monthDateFormatter.date(from: "\(monthString) \(yearString)")!)
            } else {
                let yearString = yearFormatter.string(from: objectDate!)
                return Key(sectionName: yearString, sectionDate: yearFormatter.date(from: yearString)!)
            }
        }
        
        var sections = objectsByMonth
            .sorted(by: { t1, t2 in
                if createdAt {
                    return t1.key.sectionDate > t2.key.sectionDate
                } else {
                    return t1.key.sectionDate < t2.key.sectionDate
                }
            })
            .map { (key, objects) -> TasksVC.SectionData in
                return TasksVC.SectionData(sectionName: key.sectionName, rows: objects)
        }
        
        if sortLevel == .lowToHigh {
            sections.reverse()
        }
        
        return sections
    }
    
}
