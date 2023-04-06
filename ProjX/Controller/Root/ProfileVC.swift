//
//  ProfileVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class ProfileVC: PROJXViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(logoutButtonOnClick), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureConstraints()
    }

    private func configureUI() {
        title = "Profile"
        view.addSubview(logoutButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func logoutButtonOnClick() {
        SessionManager.shared.logout()
    }

}
