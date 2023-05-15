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
        // Uncomment this line if you dont want any text to appear on the back buttons
        // self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "")
        navigationController?.navigationBar.tintColor = GlobalConstants.Colors.accentColor
        tableView.separatorColor = .secondarySystemFill
        tableView.keyboardDismissMode = .onDrag
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if tableView.style == .insetGrouped {
            self.tableView.backgroundColor = .systemGroupedBackground
        } else {
            self.view.backgroundColor = GlobalConstants.Colors.primaryBackground
            self.tableView.backgroundColor = GlobalConstants.Colors.primaryBackground
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func onTap() {
        view.endEditing(true)
    }

}
