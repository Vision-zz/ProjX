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

    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["All", "Completed", "Incomplete"])
        segmentControl.selectedSegmentIndex = 2
        segmentControl.addTarget(self, action: #selector(segmentControlValueChange), for: .valueChanged)
        segmentControl.selectedSegmentTintColor = GlobalConstants.Colors.accentColor
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentControl
    }()

    lazy var segmentControlView: UIView = {
        let segmentView = UIView()
        segmentView.backgroundColor = .clear
        segmentView.addSubview(segmentControl)
        NSLayoutConstraint.activate([
            segmentControl.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor, constant: 15),
            segmentControl.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor, constant: -15),
        ])
        return segmentView
    }()

    convenience init() {
        self.init(style: .insetGrouped)
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureNotifCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
    }

    @objc private func updateTheme() {
        segmentControl.selectedSegmentTintColor = GlobalConstants.Colors.accentColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNotifCenter()
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

    private func configureView() {
        title = "Tasks"
        tableView.backgroundView = noDataTableBackgroundView
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: TasksTableViewCell.identifier)
        tableView.tableHeaderView = segmentControlView
        let newSize = tableView.tableHeaderView!.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
        tableView.tableHeaderView!.frame.size.height = newSize.height + 25
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

    @objc private func segmentControlValueChange(_ sender: UISegmentedControl) {
        let option = AvailableDisplayOptions.init(rawValue: sender.selectedSegmentIndex)
        guard let option = option, selectedOption != option else { return }
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
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].sectionName
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        55
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
