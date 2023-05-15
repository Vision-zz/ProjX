//
//  GroupSortAndFilterDelegate.swift
//  ProjX
//
//  Created by Sathya on 10/05/23.
//

import Foundation

protocol GroupSortAndFilterDelegate: AnyObject {
    func settingsChanged(groupAndSortBy: GroupByOption, filters: Filters)
}
