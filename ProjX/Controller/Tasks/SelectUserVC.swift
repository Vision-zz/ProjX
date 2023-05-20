//
//  TeamMemberSelector.swift
//  ProjX
//
//  Created by Sathya on 17/04/23.
//

import UIKit

class SelectUserVC: PROJXTableViewController {

    lazy var team: Team! = nil
    lazy var selectedUser: User? = nil
    lazy var canClearSelection: Bool = false
    lazy var searchString: String? = nil


    struct SectionData {
        let sectionName: String
        var rows: [User]
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
    
    lazy var noSearchResultBackgroundView: UILabel = {
        let title = NSMutableAttributedString(string: "No search results!\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        let desc = NSMutableAttributedString(string: "Cannot find anything matching your search", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ])
        
        title.append(desc)
        
        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.attributedText = title
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        return noDataTitleLabel
    }()

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
        let allMembers = team.allTeamMembers.filter({ searchString == nil ? true : Util.findRange(of: searchString!.lowercased(), in: $0.name!) != nil })
        let users = Dictionary(grouping: allMembers, by: { $0.roleIn(team: team) })
            .filter({ $0.key != .none })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
            .map({ (role, users) -> SectionData in
                switch role {
                    case .owner:
                        return SectionData(sectionName: "Owner", rows: users)
                    case .admin:
                        return SectionData(sectionName: "Admins", rows: users.sorted(by: { $0.name! < $1.name! }))
                    default:
                        return SectionData(sectionName: "Members", rows: users.sorted(by: { $0.name! < $1.name! }))
                }
            })
        dataSource = users
        
    }

    @objc private func clearButtonClicked() {
        selectionDelegate?.clearedSelection?()
    }
    
    private func showSearchResultBackgroundView(_ state: Bool) {
        if state {
            tableView.backgroundView = noSearchResultBackgroundView
        } else {
            tableView.backgroundView = nil
        }
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
        
        var name = user.name ?? "---"
        if user.userID == SessionManager.shared.signedInUser?.userID {
            name += " (You)"
        }
        let nsRange = searchString != nil ? Util.findRange(of: searchString!, in: name) : nil
        cell.setTitle(name,withHighLightRange: nsRange)
        cell.setImage(image: user.getUserProfileIcon(reduceTo: CGSize(width: 15, height: 15)))
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

extension SelectUserVC: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        showSearchResultBackgroundView(false)
        if searchText.isEmpty {
            searchString = nil
            configureDataSource()
        } else {
            searchString = searchText.lowercased()
            configureDataSource()
            showSearchResultBackgroundView(dataSource.isEmpty)
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchString = nil
        showSearchResultBackgroundView(false)
        configureDataSource()
        tableView.reloadData()
    }

}
