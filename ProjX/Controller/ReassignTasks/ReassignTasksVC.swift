//
//  ReassignTeamTasksVC.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import UIKit

class ReassignTasksVC: PROJXTableViewController {
    
    struct PendingTeamTask {
        let team: Team
        let allIncompleteTasks: [TaskItem]
    }
    
    var dataSource = [PendingTeamTask]()
    var deletingUser: User! = nil
    weak var reloadDelegate: ReloadDelegate? = nil
    var allTaskCount: Int { dataSource.reduce(0, { return $0 + $1.allIncompleteTasks.count }) }

    
    var canDeleteAccount: Bool { allTaskCount == 0 }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.title = "Delete"
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = canDeleteAccount ? .systemRed : .systemGray
        button.tintColor = .white
        button.addTarget(self, action: #selector(deleteButtonOnClick), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    lazy var headerCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            deleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            deleteButton.widthAnchor.constraint(equalToConstant: 75),
        ])
        return cell
    }()
    
    lazy var noDataTableBackgroundView: UILabel = {
        
        let title = NSMutableAttributedString(string: "No pending tasks!\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        let desc = NSMutableAttributedString(string: "You've reassigned all tasks", attributes: [
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
    
    convenience init(deletingUser: User) {
        self.init(style: .insetGrouped)
        self.deletingUser = deletingUser
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDatasource()
        tableView.reloadData()
        configureTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDatasource()
        configureTitle()
    }
    
    private func configureView() {
        title = "Reassign Pending Tasks"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(ReassignTaskCell.self, forCellReuseIdentifier: ReassignTaskCell.identifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
    }

    private func configureDatasource() {
        dataSource = []
        tableView.backgroundView = nil
        for team in deletingUser.teams {
            guard deletingUser.userID! != team.teamOwner?.userID else { continue }
            let incompleteUserTasks = team.tasks.filter({ $0.assignedTo != nil && $0.assignedTo == deletingUser.userID && $0.createdBy != nil && $0.createdBy != deletingUser.userID && $0.taskStatus != .complete  })
            guard !incompleteUserTasks.isEmpty else { continue }
            dataSource.append(PendingTeamTask(team: team, allIncompleteTasks: incompleteUserTasks))
        }
        if dataSource.isEmpty {
            tableView.backgroundView = noDataTableBackgroundView
        }
        deleteButton.backgroundColor = canDeleteAccount ? .systemRed : .systemGray
    }
    
    private func configureTitle() {
        if allTaskCount == 0 {
            titleLabel.text = "All pending tasks reassigned"
        } else {
            let text = "You still have \(allTaskCount) pending task\(allTaskCount > 1 ? "s" : "") in \(dataSource.count) team\(dataSource.count > 1 ? "s" : "")."
            titleLabel.text = text
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    @objc private func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc private func deleteButtonOnClick() {
        if canDeleteAccount {
            let alert = UIAlertController(title: "Are you sure?", message: "This action is not reversible and your account will be deleted permanently. Do you want to proceed?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Proceed", style: .default) { _ in
                DataManager.shared.deleteUser(username: SessionManager.shared.signedInUser!.username!)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Pending tasks should be assigned to someone else from the same team before deleting your account. Note: Tasks that are created by and is assigned to you will be deleted automatically."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        }
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headerCell
        }
        let data = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReassignTaskCell.identifier, for: indexPath) as! ReassignTaskCell
        cell.configureCell(title: data.team.teamName!, secondaryTitle: "\(data.allIncompleteTasks.count) pending task\(data.allIncompleteTasks.count > 1 ? "s" : "")", image: data.team.getTeamIcon(reduceTo: CGSize(width: 30, height: 30)))
        cell.delegate = self
        cell.team = data.team
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let data = dataSource[indexPath.row]
            let vc = ReassignTeamTasksVC(team: data.team, deletingUser: deletingUser)
            vc.reloadDelegate = self
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        }
    }

}

extension ReassignTasksVC: ReassignForWholeTeamDelegate {
    func reassigned(for team: Team) {
        guard let tasks = dataSource.first(where: { $0.team.teamID! == team.teamID })?.allIncompleteTasks else { return }
        let vc = SelectUserForAssigningTaskVC(team: team, tasks: tasks)
        vc.delegate = self
        vc.reloadDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension ReassignTasksVC: ReassignOptionSelectionDelegate, ReloadDelegate {
    func selected(user: User, for tasks: [TaskItem], in team: Team) {
        DataManager.shared.changeTaskAssignedUser(of: tasks, to: user)
        configureDatasource()
        tableView.reloadData()
        configureTitle()
        reloadDelegate?.reloadData()
    }
    
    func selected(option: ReassignTaskOptions, for tasks: [TaskItem], in team: Team) {
        if option == .admin {
            for task in tasks {
                guard let assignToUser = team.teamAdmins.randomElement() ?? team.teamOwner else { continue }
                DataManager.shared.changeTaskAssignedUser(of: task, to: assignToUser)
            }
        } else {
            for task in tasks {
                DataManager.shared.changeTaskAssignedUser(of: task, to: task.createdByUser)
            }
        }
        configureDatasource()
        tableView.reloadData()
        configureTitle()
        reloadDelegate?.reloadData()
    }
    
    func reloadData() {
        configureDatasource()
        tableView.reloadData()
        configureTitle()
    }
    
}
