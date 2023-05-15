//
//  GroupAndSortConfigVC.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class GroupAndSortConfigVC: PROJXTableViewController {
    
    var groupAndSortBy: GroupByOption = .priority(.highToLow, .eta(.highToLow))
    var filters: Filters = Filters()
    weak var delegate: GroupSortAndFilterDelegate?
    lazy var team: Team! = nil
    lazy var selectUserForAssignedTo: Bool = true
    
    
    var assignedToUser: User? {
        get {
            return DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.assignedTo })
        }
    }
  
    var createdByUser: User? {
        get {
            return DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.createdBy })
        }
    }
    
    var priorityGroupSortAngle: CGFloat {
        switch groupAndSortBy {
            case .priority(let level, _):
                return level == .highToLow ? 0 : CGFloat.pi
            default:
                return 0
        }
    }
    
    var inlineSortAngle: CGFloat {
        switch groupAndSortBy {
            case .priority(_, let sortOption):
                switch sortOption {
                    case .createdAt(let level), .eta(let level):
                        return level == .highToLow ? 0 : CGFloat.pi
                    default:
                        return 0
                }
            case .createdAt(let sortOption), .eta(let sortOption):
                switch sortOption {
                    case .priority(let level):
                        return level == .highToLow ? 0 : CGFloat.pi
                    default:
                        return 0
                }
        }
    }
    
    var assignedToImage: UIImageView  {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let user = assignedToUser {
            imageView.image = user.getUserProfileIcon(reduceTo: CGSize(width: 30, height: 30))
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }
    
    var createdByImage: UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let user = createdByUser {
            imageView.image = user.getUserProfileIcon(reduceTo: CGSize(width: 30, height: 30))
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }
    
    var taskStatusLabel: UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        let text = filters.taskStatus == .complete ? "Completed" : filters.taskStatus == .inProgress ? "In Progress" : "All"
        label.text = text
        return label
    }
    
    convenience init(currentSettings: FilterOptions, for team: Team) {
        self.init(style: .insetGrouped)
        self.team = team
        groupAndSortBy = currentSettings.groupAndSortBy
        filters.assignedTo = currentSettings.filters?.assignedTo
        filters.createdBy = currentSettings.filters?.createdBy
        filters.taskStatus = currentSettings.filters?.taskStatus ?? .inProgress
        filters.createdBetween = currentSettings.filters?.createdBetween
        filters.etaBetween = currentSettings.filters?.etaBetween
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
        title = "Group, Sort & Filters"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(GroupSortCell.self, forCellReuseIdentifier: GroupSortCell.identifier)
        tableView.register(DatesBetweenCell.self, forCellReuseIdentifier: DatesBetweenCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupAndSortCell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked))
    }
    
    private func getAccessoryImageView(with transformAngle: CGFloat) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up")!)
        imageView.tintColor = .label
        imageView.transform = CGAffineTransform(rotationAngle: transformAngle)
        return imageView
    }
    
    @objc private func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc private func doneButtonClicked() {
        
        
        if let createdBetweenCell = tableView.cellForRow(at: IndexPath(row: 3, section: 2)) as? DatesBetweenCell {
            if createdBetweenCell.isCellSelected {
                filters.createdBetween = createdBetweenCell.selectedDates
            }
        }
        
        if let etaBetweenCell = tableView.cellForRow(at: IndexPath(row: 4, section: 2)) as? DatesBetweenCell {
            if etaBetweenCell.isCellSelected {
                filters.etaBetween = etaBetweenCell.selectedDates
            }
        }
        
        delegate?.settingsChanged(groupAndSortBy: groupAndSortBy, filters: filters)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.contentInset = UIEdgeInsets(top: -(cell.frame.origin.y), left: 0, bottom: 0, right: 0)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 3
            case 1:
                if case GroupByOption.priority = groupAndSortBy {
                    return 2
                } else {
                    return 1
                }
            case 2:
                return 5
            case 3:
                return 1
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && [3, 4].contains(indexPath.row) {
            let cell = DatesBetweenCell()
            let filter = indexPath.row == 3 ? filters.createdBetween : filters.etaBetween
            cell.setIsCellSelected(filter != nil)
            return cell.intrinsicContentSize.height
        }
        return 44
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Group By"
            case 1:
                return "Sort By"
            case 2:
                return "Filters"
            default:
                return nil
        }
    }
    
    private func configureGroupByCell(with tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupSortCell.identifier, for: indexPath) as! GroupSortCell
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.configureTitle("Priority")
            if case let GroupByOption.priority(sortLevel, _) = groupAndSortBy {
                cell.setCheckmarkState(true)
                cell.accessoryView = getAccessoryImageView(with: priorityGroupSortAngle)
                switch sortLevel {
                    case .highToLow:
                        cell.configureTitle("Priority (High > Low)")
                    case .lowToHigh:
                        cell.configureTitle("Priority (Low > High)")
                }
            }
        } else if indexPath.row == 1 {
            cell.configureTitle("Created At")
            if case GroupByOption.createdAt = groupAndSortBy {
                cell.setCheckmarkState(true)
            }
        } else {
            cell.configureTitle("Estimated Time")
            if case GroupByOption.eta = groupAndSortBy {
                cell.setCheckmarkState(true)
            }
        }
        return cell
    }
    
    private func configureSortByCell(with tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupSortCell.identifier, for: indexPath) as! GroupSortCell
        cell.selectionStyle = .none
        switch groupAndSortBy {
            case .priority(_, let sortOption):
                if indexPath.row == 0 {
                    cell.configureTitle("Created At")
                    if case let PriorityGroupSortOptions.createdAt(sortLevel) = sortOption {
                        cell.setCheckmarkState(true)
                        cell.accessoryView = getAccessoryImageView(with: inlineSortAngle)
                        switch sortLevel {
                            case .highToLow:
                                cell.configureTitle("Created At (Newest > Oldest)")
                            case .lowToHigh:
                                cell.configureTitle("Created At (Oldest > Newest)")
                        }
                    }
                } else if indexPath.row == 1 {
                    cell.configureTitle("Estimated Time")
                    if case let PriorityGroupSortOptions.eta(sortLevel) = sortOption {
                        cell.setCheckmarkState(true)
                        cell.accessoryView = getAccessoryImageView(with: inlineSortAngle)
                        switch sortLevel {
                            case .highToLow:
                                cell.configureTitle("Estimated Time (Farthest > Closest)")
                            case .lowToHigh:
                                cell.configureTitle("Estimated Time (Closest > Farthest)")
                        }
                    }
                }
            case .createdAt(let sortOption), .eta(let sortOption):
                if indexPath.row == 0 {
                    cell.configureTitle("Priority")
                    if case let TimeBasedGroupSortOptions.priority(sortLevel) = sortOption {
                        cell.setCheckmarkState(true)
                        cell.accessoryView = getAccessoryImageView(with: inlineSortAngle)
                        switch sortLevel {
                            case .highToLow:
                                cell.configureTitle("Priority (High > Low)")
                            case .lowToHigh:
                                cell.configureTitle("Priority (Low > High)")
                        }
                    }
                }
        }
        return cell
    }
    
    private func configureFilterCell(with tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DatesBetweenCell.identifier, for: indexPath) as! DatesBetweenCell
            cell.configureTitle("Created Between")
            if let createdBetween = filters.createdBetween {
                cell.setIsCellSelected(true)
                cell.configureDefaultDateFor(fromDate: createdBetween.start)
                cell.configureDefaultDateFor(toDate: createdBetween.end)
            }
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DatesBetweenCell.identifier, for: indexPath) as! DatesBetweenCell
            cell.configureTitle("ETA Between")
            if let etaBetween = filters.etaBetween {
                cell.setIsCellSelected(true)
                cell.configureDefaultDateFor(fromDate: etaBetween.start)
                cell.configureDefaultDateFor(toDate: etaBetween.end)
            }
            return cell
        } else if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupSortCell.identifier, for: indexPath) as! GroupSortCell
            cell.configureTitle("Assigned To")
            if filters.assignedTo != nil {
                cell.accessoryType = .disclosureIndicator
                cell.setCheckmarkState(true)
            }
            let image = assignedToImage
            cell.configureRightView({ rightView in
                rightView.addSubview(image)
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
                    image.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -10),
                    image.heightAnchor.constraint(equalToConstant: 30),
                    image.widthAnchor.constraint(equalToConstant: 30),
                ])
            })
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupSortCell.identifier, for: indexPath) as! GroupSortCell
            cell.configureTitle("Created By")
            if filters.createdBy != nil {
                cell.accessoryType = .disclosureIndicator
                cell.setCheckmarkState(true)
            }
            let image = createdByImage
            cell.configureRightView({ rightView in
                rightView.addSubview(image)
                NSLayoutConstraint.activate([
                    image.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
                    image.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -10),
                    image.heightAnchor.constraint(equalToConstant: 30),
                    image.widthAnchor.constraint(equalToConstant: 30),
                ])
            })
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupSortCell.identifier, for: indexPath) as! GroupSortCell
            cell.configureTitle("Task Status")
            cell.setCheckmarkState(true)
            let label = taskStatusLabel
            cell.accessoryType = .disclosureIndicator
            cell.configureRightView({ rightView in
                rightView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
                    label.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -10),
                    label.heightAnchor.constraint(equalToConstant: 30),
                ])
            })
            return cell
        }
    }
    
    private func configureResetToDefaultCell(with tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell()
        var config = UIListContentConfiguration.cell()
        config.text = "Reset to Defaults"
        config.textProperties.color = .systemBlue
        config.textProperties.alignment = .center
        cell.contentConfiguration = config
        Util.configureCustomSelectionStyle(for: cell, with: .systemBlue)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                return configureGroupByCell(with: tableView, for: indexPath)
            case 1:
                return configureSortByCell(with: tableView, for: indexPath)
            case 2:
                return configureFilterCell(with: tableView, for: indexPath)
            case 3:
                return configureResetToDefaultCell(with: tableView)
            default:
                fatalError()
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            handleDidSelectRowForGroupSection(with: indexPath)
        } else if indexPath.section == 1 {
            handleDidSelectRowForSortSection(with: indexPath)
        } else if indexPath.section == 2 {
            handleDidSelectRowForFilterSection(with: indexPath)
        } else if indexPath.section == 3 {
            filters = Filters(assignedTo: SessionManager.shared.signedInUser?.userID)
            groupAndSortBy = .priority(.highToLow, .eta(.lowToHigh))
            tableView.reloadData()
        }
    }
    
    func handleDidSelectRowForGroupSection(with indexPath: IndexPath) {
        if indexPath.row == 0 {
            handlePriorityGroupBy(for: indexPath)
        } else if indexPath.row == 1 {
            switch groupAndSortBy {
                case .createdAt(_):
                    return
                default:
                    groupAndSortBy = .createdAt(.priority(.highToLow))
                    updateGroupSortSections()
            }
        } else if indexPath.row == 2 {
            switch groupAndSortBy {
                case .eta(_):
                    return
                default:
                    groupAndSortBy = .eta(.priority(.highToLow))
                    updateGroupSortSections()
            }
        }
    }
    
    func handleDidSelectRowForSortSection(with indexPath: IndexPath) {
        switch groupAndSortBy {
            case .priority(let level, let sortOptions):
                
                if indexPath.row == 0 {
                    switch sortOptions {
                        case .createdAt(let inlineLevel):
                            let newInlineLevel: SortLevel = inlineLevel == .highToLow ? .lowToHigh : .highToLow
                            groupAndSortBy = .priority(level, .createdAt(newInlineLevel))
                            let title = newInlineLevel == .highToLow ? "Created At (Newest > Oldest)" : "Created At (Oldest > Newest)"
                            rotateAndUpdateAccessoryView(for: indexPath, with: inlineSortAngle, title: title)
                        default:
                            groupAndSortBy = .priority(level, .createdAt(.highToLow))
                            updateGroupSortSections()
                    }
                }
                
                else if indexPath.row == 1 {
                    switch sortOptions {
                        case .eta(let inlineLevel):
                            let newInlineLevel: SortLevel = inlineLevel == .highToLow ? .lowToHigh : .highToLow
                            groupAndSortBy = .priority(level, .eta(newInlineLevel))
                            let title = newInlineLevel == .highToLow ? "Estimated Time (Farthest > Closest)" : "Estimated Time (Closest > Farthest)"
                            rotateAndUpdateAccessoryView(for: indexPath, with: inlineSortAngle, title: title)
                        default:
                            groupAndSortBy = .priority(level, .eta(.highToLow))
                            updateGroupSortSections()
                    }
                }
                
                return
            case .createdAt(let sortOptions):
                if indexPath.row == 0 {
                    if case let TimeBasedGroupSortOptions.priority(inlineLevel) = sortOptions {
                        let newInlineLevel: SortLevel = inlineLevel == .highToLow ? .lowToHigh : .highToLow
                        let title = newInlineLevel == .highToLow ? "Priority (High > Low)" : "Priority (Low > High)"
                        groupAndSortBy = .createdAt(.priority(newInlineLevel))
                        rotateAndUpdateAccessoryView(for: indexPath, with: inlineSortAngle, title: title)
                    }
                }
            case .eta(let sortOptions):
                if indexPath.row == 0 {
                    if case let TimeBasedGroupSortOptions.priority(inlineLevel) = sortOptions {
                        let newInlineLevel: SortLevel = inlineLevel == .highToLow ? .lowToHigh : .highToLow
                        let title = newInlineLevel == .highToLow ? "Priority (High > Low)" : "Priority (Low > High)"
                        groupAndSortBy = .eta(.priority(newInlineLevel))
                        rotateAndUpdateAccessoryView(for: indexPath, with: inlineSortAngle, title: title)
                    }
                }
        }
    }
    
    func handleDidSelectRowForFilterSection(with indexPath: IndexPath) {
        if [3, 4].contains(indexPath.row) {
            let cell = tableView.cellForRow(at: indexPath) as! DatesBetweenCell
            cell.isCellSelected.toggle()
            if indexPath.row == 3 {
                filters.createdBetween = cell.isCellSelected ? DatesBetween() : nil
            } else {
                filters.etaBetween = cell.isCellSelected ? DatesBetween() : nil
            }
            tableView.performBatchUpdates({
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        
        if indexPath.row == 0 {
            selectUserForAssignedTo = true
            let vc = TeamMemberSelector(team: team, selectedUser: DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.assignedTo }))
            vc.selectionDelegate = self
            vc.canClearSelection = true
            vc.selectedUser = assignedToUser
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 1 {
            selectUserForAssignedTo = false
            let vc = TeamMemberSelector(team: team, selectedUser: DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.assignedTo }))
            vc.selectionDelegate = self
            vc.canClearSelection = true
            vc.selectedUser = createdByUser
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 2 {
            let vc = StatusPicker()
            vc.statusPickerDelegate = self
            vc.setSelectedStatus(filters.taskStatus)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return 200 })]
                sheet.preferredCornerRadius = 20
            }
            present(nav, animated: true)
        }
    }

    
    func updateGroupSortSections() {
        tableView.reloadData()
    }
    
    private func handlePriorityGroupBy(for indexPath: IndexPath) {
        switch groupAndSortBy {
            case .priority(let level, let sortOptions):
                let newLevel: SortLevel = level == .highToLow ? .lowToHigh : .highToLow
                groupAndSortBy = .priority(newLevel, sortOptions)
                let title = newLevel == .highToLow ? "Priority (High > Low)" : "Priority (Low > High)"
                rotateAndUpdateAccessoryView(for: indexPath, with: priorityGroupSortAngle, title: title)
            default:
                groupAndSortBy = .priority(.highToLow, .eta(.lowToHigh))
                updateGroupSortSections()
        }
    }
    
    private func rotateAndUpdateAccessoryView(for indexPath: IndexPath, with transformAngle: CGFloat, title: String) {
        let cell = tableView.cellForRow(at: indexPath) as! GroupSortCell
        UIView.animate(withDuration: 0.3, animations: {
            cell.configureTitle(title)
            cell.accessoryView?.transform = CGAffineTransform(rotationAngle: transformAngle)
        })
    }
    
}

extension GroupAndSortConfigVC: MemberSelectionDelegate {
    func selected(user: User) {
        if selectUserForAssignedTo {
            filters.assignedTo = user.userID
        } else {
            filters.createdBy = user.userID
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 2), IndexPath(row: 1, section: 2) ], with: .none)
        navigationController?.popViewController(animated: true)
    }
    
    func clearedSelection() {
        if selectUserForAssignedTo {
            filters.assignedTo = nil
        } else {
            filters.createdBy = nil
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 2), IndexPath(row: 1, section: 2) ], with: .none)
        navigationController?.popViewController(animated: true)
    }
}

extension GroupAndSortConfigVC: TaskStatusPickerDelegate {
    func selectedStatus(_ status: TaskStatus, dismiss: Bool) {
        filters.taskStatus = status
        tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .none)
        if dismiss {
            self.dismiss(animated: true)
        }
    }
    
    
}
