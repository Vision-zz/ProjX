//
//  UserInfoVC.swift
//  ProjX
//
//  Created by Sathya on 13/05/23.
//

import UIKit

class UserInfoVC: PROJXTableViewController {
    
    struct TeamData {
        var name: String
        var image: UIImage
    }
    
    lazy var user: User! = nil
    lazy var team: Team! = nil
    
    var dataSource: [TeamData] = []

    convenience init(user: User, team: Team) {
        self.init(style: .insetGrouped)
        self.user = user
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
        configureDataSource()
    }
    
    private func configureView() {
        title = "User Info"
        tableView.register(UserProfileNameCell.self, forCellReuseIdentifier: UserProfileNameCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserInfoCell")
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
    }
    
    private func configureDataSource() {
        let userTeams = Set(user.teams)
        let myTeams = Set(SessionManager.shared.signedInUser?.teams ?? [])
        
        let mutualTeams = Array(userTeams.intersection(myTeams))
            .compactMap({ TeamData(name: $0.teamName!, image: $0.getTeamIcon(reduceTo: CGSize(width: 30, height: 30))) })
            .sorted(by: { $0.name < $1.name })
        dataSource = mutualTeams
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1, 2:
                return 2
            default:
                return dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 {
            return "Teams in common"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileNameCell.identifier, for: indexPath) as! UserProfileNameCell
            cell.configure(with: user, team: team)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            let keyValueDict: [(key: String, value: String)] = [
                ("Username", "\(user.username ?? "*error*")"),
                ("Mail", "\(user.emailID ?? "*error*")"),
            ]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath)
            cell.selectionStyle = .none
            var config = UIListContentConfiguration.valueCell()
            config.text = keyValueDict[indexPath.row].key
            config.secondaryText = keyValueDict[indexPath.row].value
            
            config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
            config.textProperties.color = .secondaryLabel
            config.secondaryTextProperties.font = .systemFont(ofSize: 16)
            config.secondaryTextProperties.color = .label

            cell.contentConfiguration = config
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            let tasksInTeam = team.tasks.filter({ $0.assignedTo != nil && $0.assignedTo! == user.userID })
            let activeTasks = tasksInTeam.filter({ $0.taskStatus == .inProgress })
            
            let keyValueDict: [(key: String, value: String)] = [
                ("Tasks in team", "\(tasksInTeam.count)"),
                ("Active tasks", "\(activeTasks.count)"),
            ]
            
            var config = UIListContentConfiguration.valueCell()
            config.text = keyValueDict[indexPath.row].key
            config.secondaryText = keyValueDict[indexPath.row].value
            
            config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
            config.textProperties.color = .secondaryLabel
            config.secondaryTextProperties.font = .systemFont(ofSize: 16)
            config.secondaryTextProperties.color = .label
            Util.configureCustomSelectionStyle(for: cell)
            cell.contentConfiguration = config
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
            cell.selectionStyle = .none
            let data = dataSource[indexPath.row]
            cell.configureCellData(text: data.name, image: data.image)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            if !team.isSelected {
                let alert = UIAlertController(title: "Switch current team?", message: "\(team.teamName!) is not your current team. Do you want to set \(team.teamName!) as your current team and proceed?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
                    DataManager.shared.changeSelectedTeam(of: SessionManager.shared.signedInUser!, to: self.team)
                    if !SessionManager.shared.signedInUser!.doNotShowAgain {
                        self.showFilterModificationAlert(allTasks: indexPath.row == 0)
                    } else {
                        self.routeToTasks(allTasks: indexPath.row == 0)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            } else {
                if !SessionManager.shared.signedInUser!.doNotShowAgain {
                    self.showFilterModificationAlert(allTasks: indexPath.row == 0)
                } else {
                    self.routeToTasks(allTasks: indexPath.row == 0)
                }
            }
        }
    }
    
    private func showFilterModificationAlert(allTasks: Bool) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will modify your filter settings. Do you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { [unowned self] _ in
            self.routeToTasks(allTasks: allTasks)
        }))
        alert.addAction(UIAlertAction(title: "Don't show again", style: .default, handler: { _ in
            self.routeToTasks(allTasks: allTasks)
            SessionManager.shared.signedInUser?.doNotShowAgain(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func routeToTasks(allTasks: Bool) {
        if allTasks {
            MainRouter.shared.showUserAllTasks(of: user, for: SessionManager.shared.signedInUser!)
        } else {
            MainRouter.shared.showUserActiveTasks(of: user, for: SessionManager.shared.signedInUser!)
        }
    }

}
