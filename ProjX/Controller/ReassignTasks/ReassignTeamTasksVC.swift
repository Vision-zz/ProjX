//
//  ReassignTeamTasksVC.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import UIKit

class ReassignTeamTasksVC: PROJXTableViewController {

    var team: Team! = nil
    var deletingUser: User! = nil
    
    var dataSource = [TaskItem]()
    var isLeavingTeam = false
    var canLeaveTeam: Bool { dataSource.isEmpty }
    
    weak var reloadDelegate: ReloadDelegate? = nil
    weak var leaveTeamDelegate: LeaveTeamDelegate? = nil
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    lazy var assignAllButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.title = "Assign All"
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = GlobalConstants.Colors.accentColor
        button.tintColor = .white
        button.addTarget(self, action: #selector(assignAllButtonOnClick), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    lazy var headerCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(assignAllButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: assignAllButton.leadingAnchor, constant: -8),
            
            assignAllButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            assignAllButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            assignAllButton.widthAnchor.constraint(equalToConstant: 90),
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
    
    convenience init(team: Team, deletingUser: User) {
        self.init(style: .insetGrouped)
        self.team = team
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
        configureAssignAllButton()
    }
    
    private func configureView() {
        title = "Reassign Pending Tasks"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(ReassignTeamTaskCell.self, forCellReuseIdentifier: ReassignTeamTaskCell.identifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
    }
    
    private func configureDatasource() {
        tableView.backgroundView = nil
        dataSource = []
        dataSource = team.tasks.filter({ $0.assignedTo != nil && $0.assignedTo == deletingUser.userID && $0.createdBy != nil && $0.createdBy != deletingUser.userID && $0.taskStatus == .inProgress  })
        if dataSource.isEmpty {
            tableView.backgroundView = noDataTableBackgroundView
        }
        
    }
    
    private func configureAssignAllButton() {
        if dataSource.isEmpty {
            if isLeavingTeam {
                assignAllButton.backgroundColor = .systemRed
                var config = UIButton.Configuration.plain()
                config.buttonSize = .mini
                config.title = "Leave"
                assignAllButton.configuration = config
            } else {
                assignAllButton.isUserInteractionEnabled = false
                assignAllButton.backgroundColor = .systemGray
            }
        }
    }
    
    private func configureTitle() {
        if dataSource.count == 0 {
            titleLabel.text = "All pending tasks reassigned"
        } else {
            let text = "You still have \(dataSource.count) pending task\(dataSource.count > 1 ? "s" : "") in \(team.teamName!)."
            titleLabel.text = text
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        configureAssignAllButton()
    }
    
    @objc private func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc private func assignAllButtonOnClick() {
        if isLeavingTeam && canLeaveTeam {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(team.teamName!)'", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                SessionManager.shared.signedInUser?.leave(team: self.team)
                leaveTeamDelegate?.leftTeamAfterReassigning()
                dismiss(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }

        print("HEREEEE aswell")
        let vc = SelectUserForAssigningTaskVC(team: team, tasks: dataSource)
        vc.delegate = self
        vc.reloadDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        return 70
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Assign all your pending tasks to others or complete the tasks in this team before performing the action. Note: Tasks that are created by and is assigned to you will be deleted automatically."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headerCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReassignTeamTaskCell.identifier, for: indexPath) as! ReassignTeamTaskCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configureCell(for: dataSource[indexPath.row])
        return cell
    }

}

extension ReassignTeamTasksVC: ReassignForTaskDelegate {
    func reassinged(for task: TaskItem) {
        let vc = SelectUserForAssigningTaskVC(team: team, tasks: [task])
        vc.delegate = self
        vc.reloadDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension ReassignTeamTasksVC: ReassignOptionSelectionDelegate, ReloadDelegate {
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
