//
//  TeamInfoVC.swift
//  ProjX
//
//  Created by Sathya on 23/03/23.
//

import UIKit

class TeamInfoVC: PROJXTableViewController {

    deinit {
        print("Deinit TeamInfoVC")
    }

    lazy var team: Team! = nil
    weak var delegate: TeamExitDelegate? = nil

    lazy var teamAdmins: [User] = team.teamAdmins.sorted(by: { $0.name! < $1.name! })
    lazy var teamMembers: [User] = team.teamMembers.sorted(by: { $0.name! < $1.name! })

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
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamInfoKeyValueCell")
        tableView.register(TeamProfileCell.self, forCellReuseIdentifier: TeamProfileCell.identifier)
        tableView.register(TeamOwnerCell.self, forCellReuseIdentifier: TeamOwnerCell.identifier)
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        title = "Team Info"
    }

    private func reloadUserData() {
        teamAdmins = team.teamAdmins.sorted(by: { $0.name! < $1.name! })
        teamMembers = team.teamMembers.sorted(by: { $0.name! < $1.name! })
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
                return teamAdmins.count
            default:
                return teamMembers.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 3:
                return "Admins - \(teamAdmins.count)"
            case 4:
                return "Members - \(teamMembers.count)"
            default:
                return nil
        }
    }

    private func configureKeyValueCell(for cell: UITableViewCell, at indexPath: IndexPath) {
        guard indexPath.section == 2, indexPath.row < 3 else { return }

        let keyValueDict: [(key: String, value: String)] = [
            ("Join code", "\(team.teamJoinPasscode ?? "-")"),
            ("Active Tasks", "\(team.tasks.filter({ $0.taskStatus == .incomplete }).count)"),
            ("Total Tasks", "\(team.tasks.count)")
        ]

        if indexPath.row != 0 {
            Util.configureCustomSelectionStyle(for: cell)
            cell.accessoryType = .disclosureIndicator
        }
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

    private func configureMembersViewCell(for cell: PROJXImageTextCell, at indexPath: IndexPath) {
        let users = indexPath.section == 3 ? teamAdmins : teamMembers
        cell.accessoryType = .disclosureIndicator
        cell.cellImageView.contentMode = .scaleAspectFill
        var name = users[indexPath.row].name ?? "---"
        if users[indexPath.row].userID == SessionManager.shared.signedInUser?.userID {
            name += " (You)"
        }
        cell.configureCellData(text: name, image: users[indexPath.row].getUserProfileIcon(reduceTo: CGSize(width: 30, height: 30)))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: TeamProfileCell.identifier, for: indexPath) as! TeamProfileCell
                cell.teamOptionsDelegate = self
                cell.configureCell(team: team)
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: TeamOwnerCell.identifier, for: indexPath) as! TeamOwnerCell
                guard let owner = team.teamOwner else { return cell }
                cell.configureCell(user: owner)
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamInfoKeyValueCell", for: indexPath)
                configureKeyValueCell(for: cell, at: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
                configureMembersViewCell(for: cell, at: indexPath)
                Util.configureCustomSelectionStyle(for: cell)
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }

    private func reloadSections() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            self?.tableView.reloadSections(IndexSet(arrayLiteral: 3, 4), with: .none)
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        })
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 3 || indexPath.section == 4 {
            return indexPath
        }
        if indexPath.section == 2 {
            if indexPath.row == 1 || indexPath.row == 2 {
                return indexPath
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard [2, 3, 4].contains(indexPath.section) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            if team.isSelected {
                MainRouter.shared.routeTabbarTo(index: 0)
                MainRouter.shared.switchTasksSegmentedControlTo(option: indexPath.row == 1 ? .incomplete : .all)
            }
            else {
                let alert = UIAlertController(title: "Switch current team?", message: "\(team.teamName!) is not your current team. Do you want to set \(team.teamName!) as your current team and proceed?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] _ in
                    self.teamSelectButtonPressed()
                    MainRouter.shared.routeTabbarTo(index: 0)
                    MainRouter.shared.switchTasksSegmentedControlTo(option: indexPath.row == 1 ? .incomplete : .all)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 1 {
            return nil
        }

        if indexPath.section == 0 {
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: { [weak self] _ in
                return MenuProvider.getTeamProfileOptionsMenu(for: self!.team, delegate: self)
            })
        }

        if indexPath.section == 2 && indexPath.row == 0 {
            let passcodeRowContextMenuActionProvider: UIContextMenuActionProvider = { [weak self] _ in
                let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "square.fill.on.square.fill")) { [weak self] _ in
                    UIPasteboard.general.string = self?.team.teamJoinPasscode
                }

                var children: [UIMenuElement] = [copyAction]

                if let self = self, SessionManager.shared.signedInUser != nil && SessionManager.shared.signedInUser!.isOwner(self.team) {
                    let regenerate = UIAction(title: "Regenerate", image: UIImage(systemName: "arrow.2.squarepath")) { [weak self] _ in
                        self?.team.regeneratePasscode()
                        tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                    }
                    children.append(regenerate)
                }

                let menu = UIMenu(children: children)

                return menu
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: passcodeRowContextMenuActionProvider)
        }

        if indexPath.section == 3 && SessionManager.shared.signedInUser!.isOwner(team) {
            let adminRowContextMenuActionProvider: UIContextMenuActionProvider = { [weak self] _ in
                let demote = UIAction(title: "Demote to Member") { [weak self] _ in
                    guard let user = self?.teamAdmins[indexPath.row] else { return }
                    self!.team.makeUserMember(user)
                    self!.reloadUserData()
                    let index = self!.teamMembers.firstIndex(where: { $0.userID != nil && $0.userID == user.userID })
                    guard let index = index else {
                        tableView.reloadData()
                        return
                    }
                    tableView.moveRow(at: indexPath, to: IndexPath(row: index, section: 4))
                    self!.reloadSections()
                }

                let remove = UIAction(title: "Remove from team", attributes: .destructive) { [weak self] _ in
                    guard let user = self?.teamAdmins[indexPath.row], let team = self?.team else { return }
                    user.leave(team: team)
                    self!.reloadUserData()
                    tableView.deleteRows(at: [indexPath], with: .middle)
                    self!.reloadSections()
                }


                let menu = UIMenu(children: [demote, remove])
                return menu
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: adminRowContextMenuActionProvider)
        }

        if indexPath.section == 4 && (SessionManager.shared.signedInUser!.isOwner(team) || SessionManager.shared.signedInUser?.roleIn(team: team) == .admin) {
            let memberRowContextMenuActionProvider: UIContextMenuActionProvider = { [weak self] _ in
                var children: [UIMenuElement] = []

                if SessionManager.shared.signedInUser!.isOwner(self!.team) {
                    let promote = UIAction(title: "Promote to Admin") { [weak self] _ in
                        guard let user = self?.teamMembers[indexPath.row] else { return }
                        self?.team.makeUserAdmin(user)
                        self!.reloadUserData()
                        let index = self!.teamAdmins.firstIndex(where: { $0.userID != nil && $0.userID == user.userID })
                        guard let index = index else {
                            tableView.reloadData()
                            return
                        }
                        tableView.moveRow(at: indexPath, to: IndexPath(row: index, section: 3))
                        self!.reloadSections()
                    }
                    children.append(promote)
                }

                let remove = UIAction(title: "Remove from team", attributes: .destructive) { [weak self] _ in
                    guard let user = self?.teamMembers[indexPath.row], let team = self?.team else { return }
                    user.leave(team: team)
                    self!.reloadUserData()
                    tableView.deleteRows(at: [indexPath], with: .middle)
                    self!.reloadSections()
                }

                children.append(remove)
                let menu = UIMenu(children: children)
                return menu
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: memberRowContextMenuActionProvider)
        }

        return nil
    }
    
}

extension TeamInfoVC: TeamOptionsDelegate {
    func teamSelectButtonPressed() {
        DataManager.shared.changeSelectedTeam(of: SessionManager.shared.signedInUser!, to: team)
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }

    func teamEditButtonPressed() {
        let createTeamVc = CreateEditTeamVC()
        createTeamVc.delegate = self
        createTeamVc.configureViewForEditing(team: team)
        let nav = UINavigationController(rootViewController: createTeamVc)
        nav.modalPresentationStyle = .formSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in return 350 }), .large()]
            sheet.preferredCornerRadius = 20
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true)
    }

    func teamExitButtonPressed() {
        if let signedInUserID = SessionManager.shared.signedInUser?.userID, self.team.teamOwnerID == signedInUserID {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete team '\(self.team.teamName!)'", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                DataManager.shared.deleteTeam(self!.team)
                self?.delegate?.teamExited()
            }))
            alert.addAction(UIAlertAction(title: "Go back", style: .cancel))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(self.team.teamName!)'", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
                guard self != nil else { return }
                SessionManager.shared.signedInUser?.leave(team: self!.team)
                self?.delegate?.teamExited()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }

}

extension TeamInfoVC: CreateEditTeamDelegate {
    func changesSaved(_ team: Team) {
        dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
