//
//  ViewTaskVC.swift
//  ProjX
//
//  Created by Sathya on 11/04/23.
//

import UIKit

class ViewTaskVC: PROJXTableViewController {

    lazy var task: TaskItem! = nil

    var isAssignedToCurrentUser: Bool {
        task.assignedTo != nil && task.assignedTo! == SessionManager.shared.signedInUser?.userID
    }

    convenience init(task: TaskItem) {
        self.init(style: .insetGrouped)
        self.task = task
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
        tableView.register(TaskTitleCell.self, forCellReuseIdentifier: TaskTitleCell.identifier)
        tableView.register(TaskDescriptionCell.self, forCellReuseIdentifier: TaskDescriptionCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ViewTaskCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isAssignedToCurrentUser && task.taskStatus != .complete ? 5 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 2
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return task.taskStatus == .complete ? 4 : 3
            default:
                return 1
        }
    }

    private func configureCategoryCell(_ cell: UITableViewCell) {

        var config = UIListContentConfiguration.valueCell()
        config.text = "Priority"
        config.secondaryText = task.taskPriority == .high ? "High" : task.taskPriority == .medium ? "Medium" : "Low"

        config.imageProperties.tintColor = .label
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
    }

    private func configureUserInfoCell(_ cell: UITableViewCell, indexPath: IndexPath) {

        let keyValueDict = [
            ("Created By", task.createdByUser.name ?? "Unknown"),
            ("Assigned To", task.assignedToUser?.name ?? "None")
        ]

        var config = UIListContentConfiguration.valueCell()
        config.text = keyValueDict[indexPath.row].0
        config.secondaryText = keyValueDict[indexPath.row].1

        config.imageProperties.tintColor = .label
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
    }

    private func configureTaskStatusInfoCell(_ cell: UITableViewCell, indexPath: IndexPath) {

        let status = task.taskStatus == .incomplete ? "Incomplete" : "Completed"
        let keyValueDict = [
            ("Task Status", status),
            ("Created At", task.createdAt?.convertToString() ?? "Unknown"),
            ("Deadline", task.deadline?.convertToString() ?? "No deadline"),
            ("Completed At", task.completedAt?.convertToString() ?? "Unknown")
        ]

        var config = UIListContentConfiguration.valueCell()
        config.text = keyValueDict[indexPath.row].0
        config.secondaryText = keyValueDict[indexPath.row].1

        config.imageProperties.tintColor = .label
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
    }

    private func configureButtonCell(_ cell: UITableViewCell) {
        cell.backgroundColor = .clear

        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Mark as Completed", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8

        button.addTarget(self, action: #selector(completeButtonOnClick), for: .touchUpInside)

        cell.contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 0.75)
        ])
    }

    @objc private func completeButtonOnClick() {

        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to mark this task as completed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Mark as Completed", style: .default, handler: { [weak self] _ in
            self?.task.markTaskAsCompleted()
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)

    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 && indexPath.row == 1 {
            return indexPath
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TaskTitleCell.identifier, for: indexPath) as! TaskTitleCell
                    cell.configureTitle(task.title!)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TaskDescriptionCell.identifier) as! TaskDescriptionCell
                    cell.configureDescription(task.taskDescription ?? "----")
                    return cell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                cell.backgroundColor = GlobalConstants.Background.secondary
                configureCategoryCell(cell)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                cell.backgroundColor = GlobalConstants.Background.secondary
                configureUserInfoCell(cell, indexPath: indexPath)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                cell.backgroundColor = GlobalConstants.Background.secondary
                configureTaskStatusInfoCell(cell, indexPath: indexPath)
                return cell
            default:
                let cell = UITableViewCell()
                configureButtonCell(cell)
                return cell
                
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 1 {
            guard let desc = task.taskDescription else { return }
            let descView = DescriptionViewVC()
            descView.setDescription(desc)
            let nav = UINavigationController(rootViewController: descView)
            nav.navigationBar.prefersLargeTitles = false
            nav.modalPresentationStyle = .formSheet
            present(nav, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 100
        }
        return 44
    }

}
