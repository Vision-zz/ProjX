//
//  SelectUserForAssigningTaskVC.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import UIKit

class SelectUserForAssigningTaskVC: PROJXTableViewController {
    
    struct SectionData {
        var sectionName: String
        var rows: [User]
    }
    
    var team: Team! = nil
    var tasks: [TaskItem]! = nil
    var dataSource = [SectionData]()
    weak var delegate: ReassignOptionSelectionDelegate? = nil
    weak var reloadDelegate: ReloadDelegate? = nil
    
    var selectedIndex: IndexPath? = nil
    
    convenience init(team: Team, tasks: [TaskItem]) {
        self.init(style: .insetGrouped)
        self.team = team
        self.tasks = tasks
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
        title = "Assign To"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
        rightBarButton.tintColor = .systemGray
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func configureDataSource() {
        dataSource = []
        let users = Dictionary(grouping: team.allTeamMembers, by: { $0.roleIn(team: team) })
            .filter({ $0.key != .none })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
            .map({ (role, users) -> SectionData in
                let filteredUsers = users.filter({ $0.userID != SessionManager.shared.signedInUser!.userID })
                switch role {
                    case .owner:
                        return SectionData(sectionName: "Owner", rows: filteredUsers)
                    case .admin:
                        return SectionData(sectionName: "Admins", rows: filteredUsers.sorted(by: { $0.name! < $1.name! }))
                    default:
                        return SectionData(sectionName: "Members", rows: filteredUsers.sorted(by: { $0.name! < $1.name! }))
                }
            })
        
        dataSource = users
        
        if SessionManager.shared.signedInUser?.roleIn(team: team) == .member {
            dataSource.removeAll(where: { $0.sectionName == "Members" })
        }
        
    }
    
    @objc private func doneButtonOnClick() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        if selectedIndex.section == 0 {
            if selectedIndex.row == 0 {
                delegate?.selected(option: .admin, for: tasks, in: team)
            } else if selectedIndex.row == 1 {
                delegate?.selected(option: .createdBy, for: tasks, in: team)
            }
        } else {
            let user = dataSource[selectedIndex.section - 1].rows[selectedIndex.row]
            delegate?.selected(user: user, for: tasks, in: team)
        }
        reloadDelegate?.reloadData()
        dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return dataSource[section - 1].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 1:
                return "Owner"
            case 2:
                return "Admins - \(dataSource[section - 1].rows.count)"
            case 3:
                return "Members - \(dataSource[section - 1].rows.count)"
            default:
                return nil
        }
    }

    private func configureDefaultCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = UIListContentConfiguration.cell()
        config.text = indexPath.row == 0 ? "Team Admin" : "Created User"
        cell.contentConfiguration = config
        cell.tintColor = GlobalConstants.Colors.accentColor
        return cell
    }
    
    private func configureMembersViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
        let user = dataSource[indexPath.section - 1].rows[indexPath.row]
        cell.cellImageView.contentMode = .scaleAspectFill
        if indexPath == selectedIndex {
            cell.accessoryType = .checkmark
        }
        cell.tintColor = GlobalConstants.Colors.accentColor
        var name = user.name ?? "---"
        if user.userID == SessionManager.shared.signedInUser?.userID {
            name += " (You)"
        }
        cell.configureCellData(text: name, image: user.getUserProfileIcon(reduceTo: CGSize(width: 15, height: 15)))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureDefaultCell(for: indexPath)
        }
        return configureMembersViewCell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let selectedIndex = selectedIndex {
            let cell = tableView.cellForRow(at: selectedIndex)
            cell?.accessoryType = .none
        } else {
            navigationItem.rightBarButtonItem?.tintColor = GlobalConstants.Colors.accentColor
        }
        selectedIndex = indexPath
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }

}
