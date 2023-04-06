//
//  JoinTeamVC.swift
//  ProjX
//
//  Created by Sathya on 24/03/23.
//

import UIKit

class JoinTeamVC: PROJXViewController {
#if DEBUG
    deinit {
        print("Deinit JoinTeamVC")
    }
#endif

    weak var delegate: JoinTeamDelegate? = nil

    lazy var passcodeSearchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Enter team join code"
        searchController.searchBar.barTintColor = .clear
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.leftView = nil
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.autocorrectionType = .no
        return searchController
    }()

    lazy var invalidResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    lazy var joinButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setTitle("Join", for: .normal)
        button.addTarget(self, action: #selector(joinButtonClickced), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureConstraints()
    }

    private func configureUI() {
        title = "Join Team"
        navigationItem.searchController = passcodeSearchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(invalidResultLabel)
        view.addSubview(joinButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            joinButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            joinButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            joinButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            joinButton.heightAnchor.constraint(equalToConstant: 40),

            invalidResultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            invalidResultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
        ])
    }

    @objc private func joinButtonClickced() {

        guard let text = passcodeSearchController.searchBar.text, !text.isEmpty else {
            invalidResultLabel.text = "Enter a passcode"
            return
        }

        let team = DataManager.shared.getTeamMatching { $0.teamJoinPasscode != nil && $0.teamJoinPasscode == text }

        guard let team = team else {
            invalidResultLabel.text = "Invalid passcode"
            return
        }

        guard !SessionManager.shared.signedInUser!.isInTeam(team) else {
            invalidResultLabel.text = "User already in team"
            return
        }

        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to join team '\(team.teamName!)'", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { [weak self] _ in
            SessionManager.shared.signedInUser?.join(team: team)
            self?.delegate?.joined(team)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)

    }

}

extension JoinTeamVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if invalidResultLabel.text != nil {
            invalidResultLabel.text = nil
        }
    }
}
