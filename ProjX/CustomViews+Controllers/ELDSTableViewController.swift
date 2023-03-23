//
//  ELDSTableViewController.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import UIKit

class ELDSTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        self.view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.tableView.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }


}
