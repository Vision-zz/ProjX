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
    weak var selectedTeam: Team? = nil
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
        if (selectedTeam == nil && SessionManager.shared.signedInUser?.selectedTeamID != nil)
            || (selectedTeam != nil && selectedTeam!.teamID! != SessionManager.shared.signedInUser?.selectedTeamID)
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
        let filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), style: .plain, target: self, action: #selector(filterButtonClicked))
        navigationItem.rightBarButtonItems = [addBarButtonItem, filterBarButtonItem]
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

        let teamTasks = DataManager.shared.getAllTasks(for: selectedTeam).filter({ selectedTeam.tasksID!.contains($0.taskID!) })

        dataSource = filterOptions?.groupAndFilter(teamTasks) ?? []
        collapsedSections.forEach({ dataSource[$0].rows = [] })
        
        if dataSource.isEmpty {
            tableView.backgroundView?.isHidden = false
            if teamTasks.isEmpty {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Press the + icon to create a task")
            } else if filterOptions.filters!.totalSelectedFilters > 0 {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "No tasks satisfy the selected filters")
            }
        }
    }
    
    @objc private func filterButtonClicked() {
        let vc = GroupAndSortConfigVC(currentSettings: filterOptions, for: selectedTeam!)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
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
        let vc = AddOrEditTaskVC()
        vc.createTaskDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func generateNoDataLabelString(with string: String) -> NSMutableAttributedString {
        let title = NSMutableAttributedString(string: "No Tasks?\n", attributes: [
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
        70
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
    func settingsChanged(groupAndSortBy: GroupByOption, filters: Filters) {
        filterOptions.groupAndSortBy = groupAndSortBy
        filterOptions.filters = filters
        collapsedSections = []
        configureDataSource()
        tableView.reloadData()
        DataManager.shared.saveContext()
        dismiss(animated: true)
    }
}

extension TasksVC: TaskSectionExpandDelegate {
    func sectionExpanded(_ section: Int) {
        guard collapsedSections.contains(section) else { return }
        collapsedSections.removeAll(where: { $0 == section })
        configureDataSource()
        let numberOfRows = dataSource[section].rows.count
        var indexPaths = [IndexPath]()
        for row in 0..<numberOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        tableView.insertRows(at: indexPaths, with: .fade)
        return
    }
    
    func sectionCollapsed(_ section: Int) {
        guard !collapsedSections.contains(section) else { return }
        collapsedSections.append(section)
        configureDataSource()
        let numberOfRows = tableView.numberOfRows(inSection: section)
        var indexPaths = [IndexPath]()
        for row in 0..<numberOfRows {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        tableView.deleteRows(at: indexPaths, with: .fade)
        return
    }
}
