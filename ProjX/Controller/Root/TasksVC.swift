//
//  BrowseVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TasksVC: PROJXTableViewController {
    
    enum AvailableSegmentControlDisplayOptions: Int {
        case all, active, complete
    }
    
    private var selectedOption: AvailableSegmentControlDisplayOptions = .active
    
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
    
    enum SortOptions: String {
        case newerFirst = "Newer First"
        case olderFirst = "Older First"
        case closeETAFirst = "Closer ETA First"
        case closeETALast = "Closer ETA Last"
    }
    
    enum TaskDisplayOption: String {
        case showAllTeamTasks = "All Tasks"
        case showCreatedByMe = "Created by Me"
        case showAssignedToMe = "Assigned to Me"
    }
    
    lazy var selectedSortOption: SortOptions = .newerFirst {
        didSet {
            sortAndReloadData()
        }
    }

    lazy var selectedDisplayOption: TaskDisplayOption = .showAssignedToMe {
        didSet {
            configureDataSource()
            sortAndReloadData()
            configureHeaderViews()
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
        let segmentControl = UISegmentedControl(items: ["All", "Active", "Completed"])
        segmentControl.selectedSegmentIndex = 1
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

    lazy var rightSwipeGesture: UISwipeGestureRecognizer = {
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.cancelsTouchesInView = true
        return rightSwipeGesture
    }()

    lazy var leftSwipeGesture: UISwipeGestureRecognizer = {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.cancelsTouchesInView = true
        return leftSwipeGesture
    }()

    lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchBar.placeholder = "Search Teams"
        search.searchBar.searchBarStyle = .prominent
        search.searchBar.delegate = self
        search.delegate = self
        search.searchBar.autocapitalizationType = .none
        search.hidesNavigationBarDuringPresentation = true
        search.searchBar.returnKeyType = .search
        return search
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
        configureDataSource()
        configureRightBarButtons()
        sortAndReloadData()
        configureNotifCenter()
        configureSwipeGestures()
        configureHeaderViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDataSource()
        sortAndReloadData()
        configureHeaderViews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataSource = []
    }

    private func configureView() {
        title = "Tasks"
        tableView.backgroundView = noDataTableBackgroundView
        tableView.register(TasksTableViewCell.self, forCellReuseIdentifier: TasksTableViewCell.identifier)
    }

    func configureHeaderViews() {
        if shouldShowHeaderView() {
            tableView.tableHeaderView = segmentControlView
            let newSize = tableView.tableHeaderView!.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
            tableView.tableHeaderView!.frame.size.height = newSize.height + 25
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = nil
            navigationItem.searchController = nil
        }
    }
    
    func shouldShowHeaderView() -> Bool {
        guard let selectedTeam = selectedTeam else { return false }
        let teamTasks = DataManager.shared.getAllTasks(for: selectedTeam).filter({ task in
            if !selectedTeam.tasksID!.contains(task.taskID!) { return false }
            if selectedDisplayOption == .showAssignedToMe && task.assignedTo != SessionManager.shared.signedInUser!.userID! { return false }
            if selectedDisplayOption == .showCreatedByMe && task.createdBy != SessionManager.shared.signedInUser!.userID! { return false }
            return true
        })
        return !teamTasks.isEmpty
    }

    private func configureRightBarButtons() {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonClicked))
        
        let deferedMenuElement = UIDeferredMenuElement.uncached { [unowned self] completion in
            let showAllTeamTask = UIAction(title: TaskDisplayOption.showAllTeamTasks.rawValue, state: self.selectedDisplayOption == .showAllTeamTasks ? .on : .off,  handler: { [weak self] _ in self?.selectedDisplayOption = .showAllTeamTasks })
            let showTasksCreatedByMe = UIAction(title: TaskDisplayOption.showCreatedByMe.rawValue, state: self.selectedDisplayOption == .showCreatedByMe ? .on : .off, handler: { [weak self] _ in self?.selectedDisplayOption = .showCreatedByMe })
            let showTasksAssignedToMe = UIAction(title: TaskDisplayOption.showAssignedToMe.rawValue, state: self.selectedDisplayOption == .showAssignedToMe ? .on : .off, handler: { [weak self] _ in self?.selectedDisplayOption = .showAssignedToMe })
            let displayMenu = UIMenu(title: "Filter Tasks", options: [.displayInline, .singleSelection], children: [showTasksAssignedToMe, showTasksCreatedByMe, showAllTeamTask])
            
            let newerFirst = UIAction(title: SortOptions.newerFirst.rawValue, state: self.selectedSortOption == .newerFirst ? .on : .off, handler: { [weak self] _ in self?.selectedSortOption = .newerFirst })
            let olderFirst = UIAction(title: SortOptions.olderFirst.rawValue, state: self.selectedSortOption == .olderFirst ? .on : .off, handler: { [weak self] _ in self?.selectedSortOption = .olderFirst })
            let closeETAFirst = UIAction(title: SortOptions.closeETAFirst.rawValue, state: self.selectedSortOption == .closeETAFirst ? .on : .off, handler: { [weak self] _ in self?.selectedSortOption = .closeETAFirst })
            let closeETALast = UIAction(title: SortOptions.closeETALast.rawValue, state: self.selectedSortOption == .closeETALast ? .on : .off, handler: { [weak self] _ in self?.selectedSortOption = .closeETALast })
            let sortByMenu = UIMenu(title: "Sort By", subtitle: selectedSortOption.rawValue,  image: UIImage(systemName: "arrow.up.arrow.down"), options: [.singleSelection],  children: [newerFirst, olderFirst, closeETAFirst, closeETALast])
            
            let children = [displayMenu, sortByMenu]
            
            completion(children)
        }
        
        let menu = UIMenu(options: [.displayInline], children: [deferedMenuElement])
        let optionsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItems = [optionsBarButtonItem, addBarButtonItem]
    }
    
    private func configureSwipeGestures() {
        tableView.addGestureRecognizer(rightSwipeGesture)
        tableView.addGestureRecognizer(leftSwipeGesture)
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
            if selectedDisplayOption == .showAssignedToMe && task.assignedTo != SessionManager.shared.signedInUser!.userID! { return false }
            if selectedDisplayOption == .showCreatedByMe && task.createdBy != SessionManager.shared.signedInUser!.userID! { return false }
            if selectedOption == .all { return true }
            if selectedOption == .complete && task.taskStatus == .complete { return true }
            if selectedOption == .active && task.taskStatus == .active { return true }
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
            } else if selectedOption == .active {
                noDataTableBackgroundView.attributedText = generateNoDataLabelString(with: "Good job! There are no active tasks")
            }
        }
    }
    
    func sortAndReloadData() {
        switch selectedSortOption {
            case .newerFirst:
                for i in 0..<dataSource.count {
                    dataSource[i].rows.sort { $0.createdAt!.timeIntervalSince1970 > $1.createdAt!.timeIntervalSince1970 }
                }
            case .olderFirst:
                for i in 0..<dataSource.count {
                    dataSource[i].rows.sort { $0.createdAt!.timeIntervalSince1970 < $1.createdAt!.timeIntervalSince1970 }
                }
            case .closeETAFirst:
                for i in 0..<dataSource.count {
                    dataSource[i].rows.sort { $0.deadline!.timeIntervalSince1970 < $1.deadline!.timeIntervalSince1970 }
                }
            case .closeETALast:
                for i in 0..<dataSource.count {
                    dataSource[i].rows.sort { $0.deadline!.timeIntervalSince1970 > $1.deadline!.timeIntervalSince1970 }
                }
        }
        tableView.reloadData()
    }

    func switchSegmentControl(to option: AvailableSegmentControlDisplayOptions) {
        segmentControl.selectedSegmentIndex = option.rawValue
        segmentControlValueChange(segmentControl)
    }

    @objc func handleRightSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard selectedOption.rawValue != 0 else { return }
        let oldOption = selectedOption
        let newOption = AvailableSegmentControlDisplayOptions.init(rawValue: selectedOption.rawValue - 1) ?? selectedOption
        guard oldOption != newOption else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .preferredFramesPerSecond60], animations: {
            self.segmentControl.selectedSegmentIndex = newOption.rawValue
        }, completion: nil)
        segmentControlValueChange(segmentControl)
    }

    @objc func handleLeftSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard selectedOption.rawValue != 2 else { return }
        let oldOption = selectedOption
        let newOption = AvailableSegmentControlDisplayOptions.init(rawValue: selectedOption.rawValue + 1) ?? selectedOption
        guard oldOption != newOption else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .preferredFramesPerSecond60], animations: {
            self.segmentControl.selectedSegmentIndex = newOption.rawValue
        }, completion: nil)
        segmentControlValueChange(segmentControl)
    }

    @objc private func segmentControlValueChange(_ sender: UISegmentedControl) {
        let option = AvailableSegmentControlDisplayOptions.init(rawValue: sender.selectedSegmentIndex)
        guard let option = option, selectedOption != option else { return }
        let oldOption = selectedOption
        selectedOption = option
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: { [weak self] in
            self?.configureDataSource()
            self?.sortAndReloadData()
            self?.tableView.reloadSections(IndexSet(integersIn: 0..<self!.tableView.numberOfSections), with: sender.selectedSegmentIndex > oldOption.rawValue ? .left : .right)
        })
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
        cell.configureCell(for: task, showsCompleted: selectedOption == .all)
        cell.accessoryType = .disclosureIndicator
        Util.configureCustomSelectionStyle(for: cell)
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
    func taskCreatedOrUpdated(_ task: TaskItem) {
        configureHeaderViews()
        navigationController?.popViewController(animated: true)
        let vc = ViewTaskVC(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TasksVC: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
