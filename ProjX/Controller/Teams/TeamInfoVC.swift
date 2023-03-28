//
//  TeamInfoVC.swift
//  ProjX
//
//  Created by Sathya on 23/03/23.
//

import UIKit

class TeamInfoVC: PROJXTableViewController {

    lazy var team: Team! = nil
    weak var delegate: TeamExitDelegate? = nil

    convenience init(team: Team) {
        self.init(style: .insetGrouped)
        self.team = team
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamInfoCell")
        tableView.register(TeamProfileCell.self, forCellReuseIdentifier: TeamProfileCell.identifier)
        tableView.register(TeamOwnerCell.self, forCellReuseIdentifier: TeamOwnerCell.identifier)
        title = "Team Info"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTeam))
    }

    @objc func editTeam() {

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0, 1:
                return 1
            case 2:
                return 3
            case 3:
                return team.teamAdmins.count
            default:
                return team.teamMembers.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 3:
                return "Admins - \(team.teamAdmins.count)"
            case 4:
                return "Members - \(team.teamMembers.count)"
            default:
                return nil
        }
    }

    private func configureKeyValueCell(for cell: UITableViewCell, at indexPath: IndexPath) {
        guard indexPath.section == 2, indexPath.row < 3 else { return }

        let keyValueDict: [(key: String, value: String)] = [
            ("Join code", "\"\(team.teamJoinPasscode ?? "-")\""),
            ("Active Tasks", "\(team.tasks.filter({ $0.taskStatus == .incomplete }).count)"),
            ("Total Tasks", "\(team.tasks.count)")
        ]

        var config = cell.defaultContentConfiguration()
        config.text = keyValueDict[indexPath.row].key
        config.secondaryText = keyValueDict[indexPath.row].value
        config.prefersSideBySideTextAndSecondaryText = true

        config.imageProperties.tintColor = .label
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
    }

    private func configureMembersViewCell(for cell: UITableViewCell, at indexPath: IndexPath) {
        let users = indexPath.section == 3 ? team.teamAdmins : team.teamMembers
        var config = cell.defaultContentConfiguration()
        config.image = users[indexPath.row].userProfileImage
        config.imageProperties.tintColor = .label
        config.text = users[indexPath.row].name ?? "-"
        cell.contentConfiguration = config
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: TeamProfileCell.identifier, for: indexPath) as! TeamProfileCell
                cell.configureCell(team: team, onExitHandler: { [weak self] in
                    guard self != nil else { return }
                    if let signedInUserID = SessionManager.shared.signedInUser?.userID, self?.team.teamOwnerID == signedInUserID {
                        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete team '\(self!.team.teamName!)'", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                            self?.team.delete()
                            self?.delegate?.teamExited()
                        }))
                        alert.addAction(UIAlertAction(title: "Go back", style: .cancel))
                        self?.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(self!.team.teamName!)'", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
                            guard self != nil else { return }
                            SessionManager.shared.signedInUser?.leave(team: self!.team)
                            self?.delegate?.teamExited()
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                })
                cell.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: TeamOwnerCell.identifier, for: indexPath) as! TeamOwnerCell
                guard let owner = team.teamOwner else { return cell }
                cell.configureCell(user: owner)
                cell.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamInfoCell", for: indexPath)
                configureKeyValueCell(for: cell, at: indexPath)
                cell.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamInfoCell", for: indexPath)
                configureMembersViewCell(for: cell, at: indexPath)
                cell.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {

            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return nil
        }

        if indexPath.section == 2 && indexPath.row == 0 {
            var passcodeRowContextMenuActionProvider: UIContextMenuActionProvider = { _ in
                let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "square.fill.on.square.fill")) { [weak self] _ in
                    UIPasteboard.general.string = self?.team.teamJoinPasscode
                }

                let regenerate = UIAction(title: "Join Team", image: UIImage(systemName: "arrow.2.squarepath")) { [weak self] _ in
                    self?.team.regeneratePasscode()
                }

                let menu = UIMenu(children: [copyAction, regenerate])
                return menu
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: passcodeRowContextMenuActionProvider)
        }

//        var memberRowContextMenuActionProvider: UIContextMenuActionProvider = { _ in
//
//        }
//
//        var adminRowContextMenuActionProvider: UIContextMenuActionProvider = { _ in
//
//        }

        return nil
    }
    
}
