//
//  PROJXTableViewController.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import UIKit

class PROJXTableViewController: UITableViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return true
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        tableView.separatorColor = .secondarySystemFill
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if tableView.style == .insetGrouped {
            self.tableView.backgroundColor = .systemGroupedBackground
        } else {
            self.view.backgroundColor = GlobalConstants.Colors.primaryBackground
            self.tableView.backgroundColor = GlobalConstants.Colors.primaryBackground
        }
    }

}
