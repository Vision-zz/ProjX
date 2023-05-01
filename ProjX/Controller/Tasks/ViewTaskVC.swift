//
//  ViewTaskVC.swift
//  ProjX
//
//  Created by Sathya on 11/04/23.
//

import UIKit

class ViewTaskVC: PROJXTableViewController {

#if DEBUG
    deinit {
        print("Deinit ViewTaskVC")
    }
#endif

    lazy var task: TaskItem! = nil

    var isAssignedToCurrentUser: Bool {
        task.assignedTo != nil && task.assignedTo! == SessionManager.shared.signedInUser?.userID
    }

    var isCreatedByCurrentUser: Bool {
        task.createdBy != nil && task.createdBy! == SessionManager.shared.signedInUser?.userID
    }

    lazy var titleLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.type = .continuous
        label.numberOfLines = 1
        label.contentMode = .center
        label.speed = .rate(40)
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()

    lazy var titleHeaderView: UIView = {
        let titleView = UIView()
        titleView.backgroundColor = .clear
        titleView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -20),
        ])
        return titleView
    }()

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
        configureTitleLabelView()
    }

    private func configureView() {
        tableView.allowsSelection = true
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(TaskTitleCell.self, forCellReuseIdentifier: TaskTitleCell.identifier)
        tableView.register(TaskDescriptionCell.self, forCellReuseIdentifier: TaskDescriptionCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ViewTaskCell")
    }

    private func configureTitleLabelView() {
        titleLabel.text = task.title
        tableView.tableHeaderView = titleHeaderView
        let newSize = tableView.tableHeaderView!.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
        tableView.tableHeaderView!.frame.size.height = newSize.height + 10
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 4
        if isAssignedToCurrentUser && task.taskStatus != .complete {
            sections += 1
        }
        if isCreatedByCurrentUser {
            sections += 1
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return task.taskStatus == .complete ? 4 : 3
            case 4:
                return (isAssignedToCurrentUser && task.taskStatus != .complete) || (task.taskStatus == .complete) ? 1 : 2
            case 5:
                return task.taskStatus == .complete ? 1 : 2
            default:
                return 0
        }
    }

    private func configureCategoryCell(_ cell: UITableViewCell) {
        cell.selectionStyle = .none
        var config = UIListContentConfiguration.valueCell()
        config.text = "Priority"
        config.secondaryText = task.taskPriority == .high ? "High" : task.taskPriority == .medium ? "Medium" : "Low"

        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
    }

    private func configureUserInfoCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        cell.selectionStyle = .none
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
        cell.selectionStyle = .none
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

    private func configureMarkAsCompletedCell(_ cell: UITableViewCell) {
        var config = cell.defaultContentConfiguration()
        config.textProperties.color = .systemBlue
        config.imageProperties.tintColor = .systemBlue
        config.text = "Mark as Completed"
        config.image = UIImage(systemName: "checkmark.square")
        cell.contentConfiguration = config
        Util.configureCustomSelectionStyle(for: cell)
        cell.tag = 500
    }

    private func configureTaskOperationsCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        var config = cell.defaultContentConfiguration()
        if (indexPath.row == 0 && task.taskStatus == .complete) || indexPath.row == 1 {
            Util.configureCustomSelectionStyle(for: cell, with: .systemRed)
            config.text = "Delete Task"
            config.image = UIImage(systemName: "trash")
            config.textProperties.color = .systemRed
            config.imageProperties.tintColor = .systemRed
            cell.tag = 501
        } else if indexPath.row == 0 && task.taskStatus != .complete {
            Util.configureCustomSelectionStyle(for: cell)
            config.text = "Edit Task"
            config.image = UIImage(systemName: "square.and.pencil")
            config.textProperties.color = .systemBlue
            config.imageProperties.tintColor = .systemBlue
            cell.tag = 502
        }
        cell.contentConfiguration = config
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
        if indexPath.section == 0 || indexPath.section == 4 || indexPath.section == 5 {
            return indexPath
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Description"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: TaskDescriptionCell.identifier) as! TaskDescriptionCell
                Util.configureCustomSelectionStyle(for: cell)
                cell.configureDescription(task.taskDescription ?? "----")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                configureCategoryCell(cell)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                configureUserInfoCell(cell, indexPath: indexPath)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                configureTaskStatusInfoCell(cell, indexPath: indexPath)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                if isAssignedToCurrentUser && task.taskStatus != .complete {
                    configureMarkAsCompletedCell(cell)
                } else {
                    configureTaskOperationsCell(cell, indexPath: indexPath)
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTaskCell", for: indexPath)
                configureTaskOperationsCell(cell, indexPath: indexPath)
                return cell
            default:
                fatalError("Extra section in tableView \(#file)")
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard let desc = task.taskDescription else { return }
            let descView = DescriptionViewVC()
            descView.setDescription(desc)
            let nav = UINavigationController(rootViewController: descView)
            nav.navigationBar.prefersLargeTitles = false
            nav.modalPresentationStyle = .formSheet
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return 300 }), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(nav, animated: true)
        }

        if indexPath.section == 4 || indexPath.section == 5 {
            let cell = tableView.cellForRow(at: indexPath)
            guard let cell = cell else { return }
            switch cell.tag {
                case 500:
                    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to mark this task as completed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Mark as Completed", style: .default, handler: { [weak self] _ in
                        self?.task.markTaskAsCompleted()
                        self?.tableView.reloadData()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    present(alert, animated: true)
                case 501:
                    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this task permanently?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                        DataManager.shared.deleteTask(self!.task)
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    present(alert, animated: true)
                case 502:
                    let vc = AddOrEditTaskVC()
                    vc.configureViewForEditing(task: task)
                    vc.createTaskDelegate = self
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    return
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        }
        return 44
    }

}

extension ViewTaskVC: CreateTaskDelegate {
    func taskCreatedOrUpdated(_ task: TaskItem) {
        navigationController?.popViewController(animated: true)
        titleLabel.text = task.title
        tableView.reloadData()
    }
}
