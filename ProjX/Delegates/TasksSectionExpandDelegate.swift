//
//  TasksSectionExpandDelegate.swift
//  ProjX
//
//  Created by Sathya on 10/05/23.
//

import Foundation

protocol TaskSectionExpandDelegate: AnyObject {
    func sectionExpanded(_ section: Int)
    func sectionCollapsed(_ section: Int)
}
