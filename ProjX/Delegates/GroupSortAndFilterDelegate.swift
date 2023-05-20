//
//  GroupSortAndFilterDelegate.swift
//  ProjX
//
//  Created by Sathya on 10/05/23.
//

import Foundation

protocol GroupSortAndFilterDelegate: AnyObject {
    func filtersChanged(_ filters: Filters)
    func groupAndSortConfigChanged(_ config: GroupByOption)
    func getCurrentGroupSortConfig() -> GroupByOption
    func getCurrentFilters() -> Filters
    func showFilterVC()
}
