    //
    //  LoginVC.swift
    //  ProjX
    //
    //  Created by Sathya on 17/03/23.
    //

import UIKit

class SignupVC: ELDSTableViewController {

    var signUpDelegate: SignUpDelegate?

    

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    func configureUI() {
        title = "Sign Up"
        view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        tableView.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignInCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

}
