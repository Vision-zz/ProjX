//
//  TasksVCMenu.swift
//  ProjX
//
//  Created by Sathya on 19/05/23.
//

import UIKit

class TasksVCMenu {
    
    weak var delegate: GroupSortAndFilterDelegate? = nil
    
    func getMenu() -> UIMenu {
        
        let menuElement = UIDeferredMenuElement.uncached { [weak delegate] completion in
    
            guard let filters = delegate?.getCurrentFilters() else {
                completion([])
                return
            }
            let systemImage = filters.isDefaultFilterOption(of: SessionManager.shared.signedInUser!)
            ? UIImage(systemName: "line.3.horizontal.decrease.circle")
            : UIImage(systemName: "line.3.horizontal.decrease.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [GlobalConstants.Colors.accentColor]))
        
            let showFiltersAction = UIAction(title: "Filters", image: systemImage, handler: { _ in
                delegate?.showFilterVC()
            })
            
            guard let groupMenu = self.configureGroupMenu(), let sortMenu = self.configureSortMenu() else {
                completion([])
                return
            }
            
            completion([groupMenu, sortMenu, showFiltersAction])
            
        }
        
        
        return UIMenu(children: [menuElement])
    }
    
    
    
    private func configureGroupMenu() -> UIMenu? {
        
        guard let groupByOption = delegate?.getCurrentGroupSortConfig() else { return nil }
        
        let menuElement = UIDeferredMenuElement.uncached { [weak delegate] completion in
        
            guard let delegate = delegate else {
                completion([])
                return
            }
            
            let groupMenuElement = UIDeferredMenuElement.uncached { completion in
                
                var priorityState: UIMenuElement.State = .off
                var createdTimeState: UIMenuElement.State = .off
                var estimatedTimeState: UIMenuElement.State = .off
                
                switch groupByOption {
                    case .priority(_, _):
                        priorityState = .on
                    case .createdTime(_, _):
                        createdTimeState = .on
                    case .estimatedTime(_, _):
                        estimatedTimeState = .on
                }
                
                let priorityAction = UIAction(title: "Priority", state: priorityState, handler: { _ in
                    var prioritySortLevel: SortLevel = .highToLow
                    var priorityGroupSortOption: PriorityGroupSortOptions = .estimatedTime(.lowToHigh)
                    switch groupByOption {
                        case .priority(_, _):
                            return
                        case .createdTime(let sortLevel, let createdTimeGroupSortOptions):
                            prioritySortLevel = sortLevel
                            if case CreatedTimeGroupSortOptions.estimatedTime(let sortLevel) = createdTimeGroupSortOptions {
                                priorityGroupSortOption = .estimatedTime(sortLevel)
                            }
                        case .estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions):
                            prioritySortLevel = sortLevel
                            if case EstimatedTimeGroupSortOptions.createdTime(let sortLevel) = estimatedTimeGroupSortOptions {
                                priorityGroupSortOption = .createdTime(sortLevel)
                            }
                    }
                    let newGroupSortOption: GroupByOption = .priority(prioritySortLevel, priorityGroupSortOption)
                    delegate.groupAndSortConfigChanged(newGroupSortOption)
                })
                
                let createdTime = UIAction(title: "Created Time", state: createdTimeState, handler: { _ in
                    var createdTimeSortLevel: SortLevel = .highToLow
                    var createdTimeGroupSortOption: CreatedTimeGroupSortOptions = .estimatedTime(.lowToHigh)
                    switch groupByOption {
                        case .priority(let sortLevel, let priorityGroupSortOptions):
                            createdTimeSortLevel = sortLevel
                            createdTimeSortLevel = sortLevel
                            if case PriorityGroupSortOptions.estimatedTime(let sortLevel) = priorityGroupSortOptions {
                                createdTimeGroupSortOption = .estimatedTime(sortLevel)
                            }
                        case .createdTime(_, _):
                            return
                        case .estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions):
                            createdTimeSortLevel = sortLevel
                            if case EstimatedTimeGroupSortOptions.priority(let sortLevel) = estimatedTimeGroupSortOptions {
                                createdTimeGroupSortOption = .priority(sortLevel)
                            }
                    }
                    let newGroupSortOption: GroupByOption = .createdTime(createdTimeSortLevel, createdTimeGroupSortOption)
                    delegate.groupAndSortConfigChanged(newGroupSortOption)
                })
                
                let estimatedTime = UIAction(title: "Estimated Time", state: estimatedTimeState, handler: { _ in
                    var estimatedTimeSortLevel: SortLevel = .highToLow
                    var estimatedTimeGroupSortOption: EstimatedTimeGroupSortOptions = .createdTime(.lowToHigh)
                    switch groupByOption {
                        case .priority(let sortLevel, let priorityGroupSortOptions):
                            estimatedTimeSortLevel = sortLevel
                            if case PriorityGroupSortOptions.estimatedTime(let sortLevel) = priorityGroupSortOptions {
                                estimatedTimeGroupSortOption = .priority(sortLevel)
                            }
                        case .createdTime(let sortLevel, let createdTimeGroupSortOptions):
                            estimatedTimeSortLevel = sortLevel
                            if case CreatedTimeGroupSortOptions.priority(let sortLevel) = createdTimeGroupSortOptions {
                                estimatedTimeGroupSortOption = .priority(sortLevel)
                            }
                        case .estimatedTime(_, _):
                            return
                    }
                    let newGroupSortOption: GroupByOption = .estimatedTime(estimatedTimeSortLevel, estimatedTimeGroupSortOption)
                    delegate.groupAndSortConfigChanged(newGroupSortOption)
                })
                
                completion([priorityAction, createdTime, estimatedTime])
            }
            
            let groupMenu = UIMenu(options: [.displayInline, .singleSelection], children: [groupMenuElement])
            
            let groupSortMenuElement = UIDeferredMenuElement.uncached { completion in
                
                var highToLowString: String
                var lowToHighString: String
                var sortLevel: SortLevel
                switch groupByOption {
                    case .priority(let level, _):
                        highToLowString = "High to low"
                        lowToHighString = "Low to High"
                        sortLevel = level
                    case .createdTime(let level, _):
                        highToLowString = "Newest First"
                        lowToHighString = "Oldest First"
                        sortLevel = level
                    case .estimatedTime(let level, _):
                        highToLowString = "Farthest First"
                        lowToHighString = "Closest First"
                        sortLevel = level
                }
                
                let highToLowAction = UIAction(title: highToLowString, state: sortLevel == .highToLow ? .on : .off, handler: { _ in
                    if case let GroupByOption.priority(_, priorityGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.priority(.highToLow, priorityGroupSortOptions))
                    } else if case let GroupByOption.estimatedTime(_, estimatedTimeGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.estimatedTime(.highToLow, estimatedTimeGroupSortOptions))
                    } else if case let GroupByOption.createdTime(_, createdTimeGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.createdTime(.highToLow, createdTimeGroupSortOptions))
                    }
                })
                
                let lowToHighAction = UIAction(title: lowToHighString, state: sortLevel == .lowToHigh ? .on : .off, handler: { _ in
                    if case let GroupByOption.priority(_, priorityGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.priority(.lowToHigh, priorityGroupSortOptions))
                    } else if case let GroupByOption.estimatedTime(_, estimatedTimeGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.estimatedTime(.lowToHigh, estimatedTimeGroupSortOptions))
                    } else if case let GroupByOption.createdTime(_, createdTimeGroupSortOptions) = groupByOption {
                        delegate.groupAndSortConfigChanged(.createdTime(.lowToHigh, createdTimeGroupSortOptions))
                    }
                })

                completion([highToLowAction, lowToHighAction])
            }
            
            let groupSortMenu = UIMenu(options: [.displayInline, .singleSelection], children: [groupSortMenuElement])
            
            completion([groupMenu, groupSortMenu])
        }
        let menu = UIMenu(title: "Group By", subtitle: "\(groupByOption.toFullString)", image: UIImage(systemName: "folder"), children: [menuElement])
        return menu
        
    }
    
    private func configureSortMenu() -> UIMenu? {
        guard let groupByOption = delegate?.getCurrentGroupSortConfig() else { return nil }
        
        let menuElement = UIDeferredMenuElement.uncached { [weak delegate] completion in
            guard let delegate = delegate else {
                completion([])
                return
            }
            
            let sortMenuElement = UIDeferredMenuElement.uncached { completion in
                
                var priorityState: UIMenuElement.State = .off
                var createdTimeState: UIMenuElement.State = .off
                var estimatedTimeState: UIMenuElement.State = .off
                
                var addPriority = true
                var addCreatedTime = true
                var addEstimatedTime = true
                
                switch groupByOption {
                    case .priority(_, let priorityGroupSortOptions):
                        addPriority = false
                        switch priorityGroupSortOptions {
                            case .createdTime(_):
                                createdTimeState = .on
                            case .estimatedTime(_):
                                estimatedTimeState = .on
                        }
                    case .createdTime(_, let createdTimeGroupSortOptions):
                        addCreatedTime = false
                        switch createdTimeGroupSortOptions {
                            case .priority(_):
                                priorityState = .on
                            case .estimatedTime(_):
                                estimatedTimeState = .on
                        }
                    case .estimatedTime(_, let estimatedTimeGroupSortOptions):
                        addEstimatedTime = false
                        switch estimatedTimeGroupSortOptions {
                            case .priority(_):
                                priorityState = .on
                            case .createdTime(_):
                                createdTimeState = .on
                        }
                }
                
                let prioritySortAction = UIAction(title: "Priority", state: priorityState, handler: { _ in
                    if case GroupByOption.createdTime(let sortLevel, let createdTimeGroupSortOptions) = groupByOption {
                        if case CreatedTimeGroupSortOptions.estimatedTime(let inlineSortLevel) = createdTimeGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .priority(inlineSortLevel)))
                        }
                    } else if case GroupByOption.estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions) = groupByOption {
                        if case EstimatedTimeGroupSortOptions.createdTime(let inlineSortLevel) = estimatedTimeGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .priority(inlineSortLevel)))
                        }
                    }
                })
                
                let createdTimeAction = UIAction(title: "Created Time", state: createdTimeState, handler: { _ in
                    if case GroupByOption.priority(let sortLevel, let priorityGroupSortOptions) = groupByOption {
                        if case PriorityGroupSortOptions.estimatedTime(let inlineSortLevel) = priorityGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.priority(sortLevel, .createdTime(inlineSortLevel)))
                        }
                    } else if case GroupByOption.estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions) = groupByOption {
                        if case EstimatedTimeGroupSortOptions.priority(let inlineSortLevel) = estimatedTimeGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .createdTime(inlineSortLevel)))
                        }
                    }
                })
                
                let estimatedTime = UIAction(title: "Estimated Time", state: estimatedTimeState, handler: { _ in
                    if case GroupByOption.priority(let sortLevel, let priorityGroupSortOptions) = groupByOption {
                        if case PriorityGroupSortOptions.estimatedTime(let inlineSortLevel) = priorityGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.priority(sortLevel, .estimatedTime(inlineSortLevel)))
                        }
                    } else if case GroupByOption.createdTime(let sortLevel, let createdTimeGroupSortOptions) = groupByOption {
                        if case CreatedTimeGroupSortOptions.estimatedTime(let inlineSortLevel) = createdTimeGroupSortOptions {
                            delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .estimatedTime(inlineSortLevel)))
                        }
                    }
                })
                
                var children = [UIMenuElement]()
                
                if addPriority {
                    children.append(prioritySortAction)
                }
                if addCreatedTime {
                    children.append(createdTimeAction)
                }
                if addEstimatedTime {
                    children.append(estimatedTime)
                }
                
                completion(children)
            }
            
            let sortMenu = UIMenu(options: [.displayInline, .singleSelection], children: [sortMenuElement])
            
            let sortByMenuElement = UIDeferredMenuElement.uncached { completion in
                
                
                var highToLowString: String
                var lowToHighString: String
                var sortLevel: SortLevel
                
                switch groupByOption {
                    case .priority(_, let priorityGroupSortOptions):
                        switch priorityGroupSortOptions {
                            case .createdTime(let level):
                                sortLevel = level
                                highToLowString = "Newest First"
                                lowToHighString = "Oldest First"
                            case .estimatedTime(let level):
                                sortLevel = level
                                highToLowString = "Farthest First"
                                lowToHighString = "Closest First"
                        }
                    case .createdTime(_, let createdTimeGroupSortOptions):
                        switch createdTimeGroupSortOptions {
                            case .priority(let level):
                                sortLevel = level
                                highToLowString = "High to low"
                                lowToHighString = "Low to High"
                            case .estimatedTime(let level):
                                sortLevel = level
                                highToLowString = "Farthest First"
                                lowToHighString = "Closest First"
                        }
                    case .estimatedTime(_, let estimatedTimeGroupSortOptions):
                        switch estimatedTimeGroupSortOptions {
                            case .priority(let level):
                                sortLevel = level
                                highToLowString = "High to low"
                                lowToHighString = "Low to High"
                            case .createdTime(let level):
                                sortLevel = level
                                highToLowString = "Newest First"
                                lowToHighString = "Oldest First"
                        }
                }
                
                let highToLowAction = UIAction(title: highToLowString, state: sortLevel == .highToLow ? .on : .off, handler: { _ in
                    switch groupByOption {
                        case .priority(let sortLevel, let priorityGroupSortOptions):
                            switch priorityGroupSortOptions {
                                case .createdTime(_):
                                    delegate.groupAndSortConfigChanged(.priority(sortLevel, .createdTime(.highToLow)))
                                case .estimatedTime(_):
                                    delegate.groupAndSortConfigChanged(.priority(sortLevel, .estimatedTime(.highToLow)))
                            }
                        case .createdTime(let sortLevel, let createdTimeGroupSortOptions):
                            switch createdTimeGroupSortOptions {
                                case .priority(_):
                                    delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .priority(.highToLow)))
                                case .estimatedTime(_):
                                    delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .estimatedTime(.highToLow)))
                            }
                        case .estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions):
                            switch estimatedTimeGroupSortOptions {
                                case .priority(_):
                                    delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .priority(.highToLow)))
                                case .createdTime(_):
                                    delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .createdTime(.highToLow)))
                            }
                    }
                })
                
                let lowToHighAction = UIAction(title: lowToHighString, state: sortLevel == .lowToHigh ? .on : .off, handler: { _ in
                    switch groupByOption {
                        case .priority(let sortLevel, let priorityGroupSortOptions):
                            switch priorityGroupSortOptions {
                                case .createdTime(_):
                                    delegate.groupAndSortConfigChanged(.priority(sortLevel, .createdTime(.lowToHigh)))
                                case .estimatedTime(_):
                                    delegate.groupAndSortConfigChanged(.priority(sortLevel, .estimatedTime(.lowToHigh)))
                            }
                        case .createdTime(let sortLevel, let createdTimeGroupSortOptions):
                            switch createdTimeGroupSortOptions {
                                case .priority(_):
                                    delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .priority(.lowToHigh)))
                                case .estimatedTime(_):
                                    delegate.groupAndSortConfigChanged(.createdTime(sortLevel, .estimatedTime(.lowToHigh)))
                            }
                        case .estimatedTime(let sortLevel, let estimatedTimeGroupSortOptions):
                            switch estimatedTimeGroupSortOptions {
                                case .priority(_):
                                    delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .priority(.lowToHigh)))
                                case .createdTime(_):
                                    delegate.groupAndSortConfigChanged(.estimatedTime(sortLevel, .createdTime(.lowToHigh)))
                            }
                    }
                })
                
                completion([highToLowAction, lowToHighAction])
                
            }
            
            let sortByMenu = UIMenu(options: [.displayInline, .singleSelection], children: [sortByMenuElement])
            
            completion([sortMenu, sortByMenu])
            
        }
        
        var sortByConfigString: String
        switch groupByOption {
            case .priority(_, let priorityGroupSortOptions):
                sortByConfigString = priorityGroupSortOptions.toString
            case .createdTime(_, let createdTimeGroupSortOptions):
                sortByConfigString = createdTimeGroupSortOptions.toString
            case .estimatedTime(_, let estimatedTimeGroupSortOptions):
                sortByConfigString = estimatedTimeGroupSortOptions.toString
        }
        
        let menu = UIMenu(title: "Sort By", subtitle: "\(sortByConfigString)", image: UIImage(systemName: "arrow.up.arrow.down"), children: [menuElement])
        return menu
    }
    
    
}
