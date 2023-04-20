//
//  TeamMemberSelector.swift
//  ProjX
//
//  Created by Sathya on 17/04/23.
//

import UIKit

class TeamMemberSelector: PROJXTableViewController {

    lazy var team: Team! = nil
    lazy var selectedUser: User? = nil
    lazy var teamAdmins: [User] = team.teamAdmins.sorted(by: { $0.name! < $1.name! })
    lazy var teamMembers: [User] = team.teamMembers.sorted(by: { $0.name! < $1.name! })

    weak var selectionDelegate: AssignedToSelectionDelegate?

    convenience init(team: Team, selectedUser: User?) {
        self.init(style: .grouped)
        self.team = team
        self.selectedUser = selectedUser
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
        title = "Select User"
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return teamAdmins.count
        } else {
            return teamMembers.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Owner"
        } else if section == 1 {
            return "Admins"
        } else {
            return "Members"
        }
    }

    private func configureMembersViewCell(for cell: PROJXImageTextCell, at indexPath: IndexPath) {
        let user = (indexPath.section == 0 ? [team.teamOwner!] : indexPath.section == 1 ? teamAdmins : teamMembers)[indexPath.row]
        cell.cellImageView.contentMode = .scaleAspectFill
        if user.userID! == selectedUser?.userID {
            cell.accessoryType = .checkmark
        }
        var name = user.name ?? "---"
        if user.userID == SessionManager.shared.signedInUser?.userID {
            name += " (You)"
        }
        cell.configureCellData(text: name, image: user.getUserProfileIcon(reduceTo: CGSize(width: 15, height: 15)))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
        configureMembersViewCell(for: cell, at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectionDelegate?.taskAssigned(to: team.teamOwner!)
        } else if indexPath.section == 1 {
            selectionDelegate?.taskAssigned(to: teamAdmins[indexPath.row])
        } else {
            selectionDelegate?.taskAssigned(to: teamMembers[indexPath.row])
        }
    }

}
