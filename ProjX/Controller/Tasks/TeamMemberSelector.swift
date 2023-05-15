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
    lazy var canClearSelection: Bool = false

    struct SectionData {
        let sectionName: String
        let rows: [User]
    }

    var dataSource = [SectionData]()

    weak var selectionDelegate: MemberSelectionDelegate?

    lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchBar.placeholder = "Search Members"
        search.searchBar.searchBarStyle = .prominent
        search.searchBar.delegate = self
        search.delegate = self
        search.searchBar.autocapitalizationType = .none
        search.hidesNavigationBarDuringPresentation = true
        search.searchBar.returnKeyType = .done
        return search
    }()

    lazy var isSearchBarVisible = false

    convenience init(team: Team, selectedUser: User?) {
        self.init(style: .insetGrouped)
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
        configureDataSource()
    }

    private func configureView() {
        title = "Select User"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        if canClearSelection {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonClicked))
        }
        
    }

    private func configureDataSource() {
        dataSource = []
        dataSource.append(SectionData(sectionName: "Owner", rows: [team.teamOwner!]))
        dataSource.append(SectionData(sectionName: "Admins", rows: team.teamAdmins.sorted(by: { $0.name! < $1.name! })))
        dataSource.append(SectionData(sectionName: "Members", rows: team.teamMembers.sorted(by: { $0.name! < $1.name! })))
    }

    @objc private func clearButtonClicked() {
        selectionDelegate?.clearedSelection?()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    private func configureMembersViewCell(for cell: PROJXImageTextCell, at indexPath: IndexPath) {
        let user = dataSource[indexPath.section].rows[indexPath.row]
        cell.cellImageView.contentMode = .scaleAspectFill
        if user.userID! == selectedUser?.userID {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        var name = user.name ?? "---"
        if user.userID == SessionManager.shared.signedInUser?.userID {
            name += " (You)"
        }
        cell.configureCellData(text: name, image: user.getUserProfileIcon(reduceTo: CGSize(width: 15, height: 15)))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
        Util.configureCustomSelectionStyle(for: cell)
        configureMembersViewCell(for: cell, at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = dataSource[indexPath.section].rows[indexPath.row]
        selectionDelegate?.selected(user: user)
    }

}

extension TeamMemberSelector: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            configureDataSource()
        }
        else {
            var ownerArr = [User]()
            var adminArr = [User]()
            var memberArr = [User]()
            
            for member in team.allTeamMembers {
                let match = member.name?.lowercased().starts(with: searchText.lowercased())
                guard let _ = match, match == true else { continue }
                if member.roleIn(team: team) == .owner {
                    ownerArr.append(member)
                } else if member.roleIn(team: team) == .admin {
                    adminArr.append(member)
                } else {
                    memberArr.append(member)
                }
            }

            dataSource = []
            if !ownerArr.isEmpty {
                dataSource.append(SectionData(sectionName: "Owner", rows: ownerArr))
            }
            if !adminArr.isEmpty {
                dataSource.append(SectionData(sectionName: "Admins", rows: adminArr))
            }
            if !memberArr.isEmpty {
                dataSource.append(SectionData(sectionName: "Members", rows: memberArr))
            }
        }

        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        configureDataSource()
        tableView.reloadData()
    }

}
