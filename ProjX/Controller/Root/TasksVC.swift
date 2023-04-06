//
//  BrowseVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TasksVC: PROJXTableViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    lazy var dataSource: [TaskItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = "Tasks"
        
    }

//    private func configureDataSource() {
//        var task = TaskItem(context: DataManager.shared.context)
//        task.
//        dataSource.append(TaskI)
//    }

}
