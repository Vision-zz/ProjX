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
        self.view.backgroundColor = GlobalConstants.Background.primary
        self.tableView.backgroundColor = GlobalConstants.Background.primary
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }


}
