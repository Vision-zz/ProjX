//
//  StatusUpdateDelegate.swift
//  ProjX
//
//  Created by Sathya on 15/05/23.
//

import Foundation

protocol StatusUpdateCollapseDelegate: AnyObject {
    func cellExpanded(atIndexPath indexPath: IndexPath)
    func cellCollapsed(atIndexPath indexPath: IndexPath)
}

protocol StatusUpdateDelegate: AnyObject {
    func statusUpdateCreated(_ statusUpdate: TaskStatusUpdate)
    func statusUpdateEdited(_ statusUpdate: TaskStatusUpdate)
}
