//
//  BrowseVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TasksVC: PROJXTableViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    var showsFilterButton: Bool = false
    
    struct SectionData {
        let sectionName: String
        var rows: [TaskItem]
        
        init(sectionName: String, rows: [TaskItem]) {
            self.sectionName = sectionName
            self.rows = rows
        }
    }

    var firstLaunch = true
    lazy var dataSource: [SectionData] = []
    lazy var collapsedSections = [Int]()
    lazy var selectedTeam: Team? = nil
    weak var filterOptions: FilterOptions! = nil

    lazy var noDataTableBackgroundView: UILabel = {
        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        return noDataTitleLabel
    }()

    lazy var teamSelectButton: TeamSelectButton = {
        let button = TeamSelectButton()
        button.addTarget(self, action: #selector(teamSelectButtonClick), for: .touchUpInside)
        return button
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
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDataSource()
        configureRightBarButtons()
        configureNotifCenter()
        firstLaunch = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRightBarButtons()
        if (selectedTeam == nil && SessionManager.shared.signedInUser?.selectedTeamID != nil)
            || (SessionManager.shared.signedInUser?.selectedTeamID != nil && selectedTeam?.teamID != SessionManager.shared.signedInUser?.selectedTeamID)
        {
            collapsedSections = []
        }
        guard !firstLaunch else { return }
        updateView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataSource = []
    }
    
    func updateView() {
        configureDataSource()
        tableView.reloadData()
    }

    private func configureView() {
        title = "Tasks"
        tableView.backgroundView = noDataTableBackgroundView
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: TasksTableViewCell.identifier)
        tableView.register(TasksHeaderView.self, forHeaderFooterViewReuseIdentifier: TasksHeaderView.identifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: teamSelectButton)
    }

    private func configureRightBarButtons() {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonClicked))
        let tasksVCMenu = TasksVCMenu()
        tasksVCMenu.delegate = self
        let optionsButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: tasksVCMenu.getMenu())
        var barButtonItems = [optionsButtonItem, addBarButtonItem]
        if !filterOptions.filters.isDefaultFilterOption(of: SessionManager.shared.signedInUser!) {
            let filterButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), style: .done, target: self, action: #selector(filterButtonClicked))
            barButtonItems.append(filterButtonItem)
        }
        navigationItem.setRightBarButtonItems(barButtonItems, animated: true)
    }
    
    @objc private func filterButtonClicked() {
        showFilterVC()
    }


    private func configureDataSource() {
        filterOptions = SessionManager.shared.signedInUser!.taskFilterSettings
        dataSource = []
        selectedTeam = SessionManager.shared.signedInUser?.selectedTeam
        teamSelectButton.configureButton(for: selectedTeam)
        tableView.backgroundView?.isHidden = true
        guard let selectedTeam = selectedTeam else {
            tableView.backgroundView?.isHidden = false
            noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Head over to teams tab to get yourself into a team")
            return
        }

        let teamTasks = DataManager.shared.getTasks(for: selectedTeam).filter({ selectedTeam.tasksID!.contains($0.taskID!) })

        dataSource = filterOptions?.groupAndFilter(teamTasks) ?? []
        collapsedSections.forEach({ dataSource[$0].rows = [] })
        
        if dataSource.isEmpty {
            tableView.backgroundView?.isHidden = false
            if teamTasks.isEmpty {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Press the + icon to create a task")
            } else if filterOptions.filters.totalSelectedFilters > 0 {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "No tasks satisfy the selected filters")
            }
        }
    }
    
    @objc private func teamSelectButtonClick() {
        let vc = TeamSelectionVC()
        vc.teamSelectDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = GlobalConstants.Colors.accentColor
        nav.modalPresentationStyle = .formSheet
        if let sheetController = nav.sheetPresentationController {
            sheetController.prefersGrabberVisible = true
            sheetController.detents = [.medium(), .large()]
        }
        present(nav, animated: true)
    }
    
    @objc func addBarButtonClicked() {
        guard let _ = selectedTeam else {
            let alert = UIAlertController(title: "Current team not set", message: "You need to set a team as your current team to Add tasks", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let vc = AddOrEditTaskVC()
        vc.createTaskDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func generateNoDataLabelString(with string: String) -> NSMutableAttributedString {
        let title = NSMutableAttributedString(string: "Can't find anything?\n", attributes: [
            .font: UIFont.systemFont(ofSize: 23, weight: .bold),
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
        cell.configureCell(for: task, showsCompleted: true)
        cell.accessoryType = .disclosureIndicator
        cell.delegate = self
        Util.configureCustomSelectionStyle(for: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TasksHeaderView.identifier) as! TasksHeaderView
        headerView.configureLabel(dataSource[section].sectionName)
        headerView.associatedSection = section
        headerView.delegate = self
        headerView.setHeaderIsCollapsed(collapsedSections.contains(section))
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = dataSource[indexPath.section].rows[indexPath.row]
        let taskViewVC = ViewTaskVC(task: task)
        navigationController?.pushViewController(taskViewVC, animated: true)
    }

}

extension TasksVC: CreateTaskDelegate {
    func taskCreatedOrUpdated(_ task: TaskItem) {
        navigationController?.popViewController(animated: true)
        let vc = ViewTaskVC(task: task)
        navigationController?.pushViewController(vc, animated: true)

    }
}

extension TasksVC: TeamSelectDelegate {
    func teamSelected(team: Team) {
        DataManager.shared.changeSelectedTeam(of: SessionManager.shared.signedInUser!, to: team)
        dismiss(animated: true)
        teamSelectButton.configureButton(for: team)
        let numberOfSections = dataSource.count
        collapsedSections = []
        configureDataSource()
        tableView.performBatchUpdates({
            tableView.deleteSections(IndexSet(integersIn: 0..<numberOfSections), with: .right)
            self.tableView.insertSections(IndexSet(integersIn: 0..<self.dataSource.count), with: .left)
        })
    }
}

extension TasksVC: GroupSortAndFilterDelegate {
    func filtersChanged(_ filters: Filters) {
        filterOptions.filters = filters
        collapsedSections = []
        configureDataSource()
        tableView.reloadData()
        DataManager.shared.saveContext()
        configureRightBarButtons()
        dismiss(animated: true)
    }
    
    func groupAndSortConfigChanged(_ config: GroupByOption) {
        filterOptions.groupAndSortBy = config
        collapsedSections = []
        configureDataSource()
        tableView.performBatchUpdates({
            tableView.deleteSections(IndexSet(integersIn: 0..<tableView.numberOfSections), with: .fade)
            tableView.insertSections(IndexSet(integersIn: 0..<dataSource.count), with: .fade)
        })
        tableView.reloadData()
        DataManager.shared.saveContext()
    }
    
    func getCurrentGroupSortConfig() -> GroupByOption {
        return filterOptions.groupAndSortBy
    }
    
    func getCurrentFilters() -> Filters {
        return filterOptions.filters
    }
    
    func showFilterVC() {
        guard let selectedTeam = selectedTeam else {
            let alert = UIAlertController(title: "Current team not set", message: "You need to set a team as your current team to view and filter tasks.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let vc = FiltersVC(currentSettings: filterOptions, for: selectedTeam)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension TasksVC: TaskSectionExpandDelegate {
    func sectionExpanded(_ section: Int) {
        guard collapsedSections.contains(section) else { return }
        collapsedSections.removeAll(where: { $0 == section })
        tableView.beginUpdates()
        configureDataSource()
        let numberOfRows = dataSource[section].rows.count
        var indexPaths = [IndexPath]()
        for row in 0..<numberOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
        return
    }
    
    func sectionCollapsed(_ section: Int) {
        guard !collapsedSections.contains(section) else { return }
        collapsedSections.append(section)
        tableView.beginUpdates()
        configureDataSource()
        let numberOfRows = tableView.numberOfRows(inSection: section)
        var indexPaths = [IndexPath]()
        for row in 0..<numberOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        tableView.deleteRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
        return
    }
}


extension TasksVC: MarkAsCompleteActionDelegate {
    func markAsCompletedActionTriggered(for taskItem: TaskItem) {
        var indexPath: IndexPath? = nil
        for (section, sectionData) in dataSource.enumerated() {
            for (row, rowData) in sectionData.rows.enumerated() {
                if rowData.taskID == taskItem.taskID {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        guard let assignedTo = taskItem.assignedTo, SessionManager.shared.signedInUser?.userID == assignedTo else {
            let alert = UIAlertController(title: "Permission Denied", message: "You are not allowed to do this action. This task is not assigned to you.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        guard let indexPath = indexPath else { return }
        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to mark this task as completed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Mark as Completed", style: .default, handler: { [weak self] _ in
            taskItem.markTaskAsCompleted()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
