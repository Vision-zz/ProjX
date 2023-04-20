//
//  BrowseVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TasksVC: PROJXTableViewController {

    private enum AvailableDisplayOptions: Int {
        case all, complete, incomplete
    }

    private var selectedOption: AvailableDisplayOptions = .incomplete

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    struct SectionData {
        let sectionName: String
        var rows: [TaskItem]

        init(sectionName: String, rows: [TaskItem]) {
            self.sectionName = sectionName
            self.rows = rows
        }
    }

    lazy var dataSource: [SectionData] = []
    lazy var selectedTeam: Team? = nil

    lazy var noDataTableBackgroundView: UILabel = {
        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        return noDataTitleLabel
    }()

    lazy var allButton: UIButton = {
        let button = UIButton()
        button.tag = AvailableDisplayOptions.all.rawValue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray5
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = selectedOption == .all ? 1.5 : 0
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitle("All", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(categoryButtonClicked), for: .touchUpInside)
        return button
    }()

    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.tag = AvailableDisplayOptions.complete.rawValue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray5
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = selectedOption == .complete ? 1.5 : 0
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitle("Completed", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(categoryButtonClicked), for: .touchUpInside)
        return button
    }()

    lazy var incompleteButton: UIButton = {
        let button = UIButton()
        button.tag = AvailableDisplayOptions.incomplete.rawValue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGray5
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = selectedOption == .incomplete ? 1.5 : 0
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitle("Incomplete", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(categoryButtonClicked), for: .touchUpInside)
        return button
    }()

    lazy var categoryView: UIView = {
        let cv = UIView()
        cv.addSubview(allButton)
        cv.addSubview(completeButton)
        cv.addSubview(incompleteButton)
        NSLayoutConstraint.activate([
            allButton.heightAnchor.constraint(equalToConstant: 30),
            allButton.widthAnchor.constraint(equalToConstant: allButton.intrinsicContentSize.width + 20),
            completeButton.heightAnchor.constraint(equalToConstant: 30),
            completeButton.widthAnchor.constraint(equalToConstant: completeButton.intrinsicContentSize.width + 25),
            incompleteButton.heightAnchor.constraint(equalToConstant: 30),
            incompleteButton.widthAnchor.constraint(equalToConstant: incompleteButton.intrinsicContentSize.width + 25),

            allButton.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),
            completeButton.leadingAnchor.constraint(equalTo: allButton.trailingAnchor, constant: 10),
            incompleteButton.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: 10)
        ])
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDataSource()
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataSource = []
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
            allButton.layer.borderColor = UIColor.label.cgColor
            completeButton.layer.borderColor = UIColor.label.cgColor
            incompleteButton.layer.borderColor = UIColor.label.cgColor
        }
    }

    private func configureView() {
        title = "Tasks"
        tableView.backgroundView = noDataTableBackgroundView
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: TasksTableViewCell.identifier)
        tableView.tableHeaderView = categoryView
        let newSize = tableView.tableHeaderView!.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
        tableView.tableHeaderView!.frame.size.height = newSize.height + 20
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonClicked))
        navigationItem.rightBarButtonItems = [addBarButtonItem]
    }


    private func configureDataSource() {
        dataSource = []
        selectedTeam = SessionManager.shared.signedInUser?.selectedTeam
        tableView.backgroundView?.isHidden = true
        guard let selectedTeam = selectedTeam else {
            tableView.backgroundView?.isHidden = false
            noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Head over to teams tab to get yourself into a team")
            return
        }

        let teamTasks = DataManager.shared.getAllTasks(for: selectedTeam).filter({ task in
            if !selectedTeam.tasksID!.contains(task.taskID!) { return false }
            if selectedOption == .all { return true }
            if selectedOption == .complete && task.taskStatus == .complete { return true }
            if selectedOption == .incomplete && task.taskStatus == .incomplete { return true }
            return false
        })

        let highPriorityTasks = teamTasks.filter({ $0.taskPriority == .high })
        if !highPriorityTasks.isEmpty {
            dataSource.append(SectionData(sectionName: "High Priority", rows: highPriorityTasks))
        }

        let mediumPriorityTasks = teamTasks.filter({ $0.taskPriority == .medium })
        if !mediumPriorityTasks.isEmpty {
            dataSource.append(SectionData(sectionName: "Medium Priority", rows: mediumPriorityTasks))
        }

        let lowPriorityTasks = teamTasks.filter({ $0.taskPriority == .low })
        if !lowPriorityTasks.isEmpty {
            dataSource.append(SectionData(sectionName: "Low Priority", rows: lowPriorityTasks))
        }
        if dataSource.isEmpty {
            tableView.backgroundView?.isHidden = false
            if selectedOption == .all || teamTasks.isEmpty {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Press the + icon to create a task")
            } else if selectedOption == .complete {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Probably there are no completed tasks")
            } else if selectedOption == .incomplete {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Good job! There are no incomplete tasks")
            }
        }

    }

    @objc private func categoryButtonClicked(_ sender: UIButton) {
        let option = AvailableDisplayOptions.init(rawValue: sender.tag)
        guard let option = option, selectedOption != option else { return }
        completeButton.layer.borderWidth = option == .complete ? 1.5 : 0
        incompleteButton.layer.borderWidth = option == .incomplete ? 1.5 : 0
        allButton.layer.borderWidth = option == .all ? 1.5 : 0
        selectedOption = option
        configureDataSource()
        tableView.reloadData()
    }

    @objc func addBarButtonClicked() {
        let vc = AddTaskVC()
        vc.createTaskDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func generateNoDataLabelString(with string: String) -> NSMutableAttributedString {
        let title = NSMutableAttributedString(string: "Can't find what you're looking for?\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])

        title.append(NSMutableAttributedString(string: string, attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]))
        return title
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TasksTableViewCell.identifier, for: indexPath) as! TasksTableViewCell
        let task = dataSource[indexPath.section].rows[indexPath.row]
        cell.configureCell(for: task, showsCompleted: selectedOption == .all)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = GlobalConstants.Background.primary
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].sectionName
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = dataSource[indexPath.section].rows[indexPath.row]
        let taskViewVC = ViewTaskVC(task: task)
        navigationController?.pushViewController(taskViewVC, animated: true)
    }

}

extension TasksVC: CreateTaskDelegate {
    func taskCreated(_ task: TaskItem) {
        navigationController?.popViewController(animated: true)
    }
}
