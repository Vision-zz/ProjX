//
//  GroupAndSortConfigVC.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class FiltersVC: PROJXTableViewController {
    
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
        filters.assignedTo = currentSettings.filters.assignedTo
        filters.createdBy = currentSettings.filters.createdBy
        filters.taskStatus = currentSettings.filters.taskStatus
        filters.createdBetween = currentSettings.filters.createdBetween
        filters.etaBetween = currentSettings.filters.etaBetween
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
        title = "Filters"
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
        
        delegate?.filtersChanged(filters)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 5
            case 1:
                return 1
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && [3, 4].contains(indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: DatesBetweenCell.identifier) as! DatesBetweenCell
            let filter = indexPath.row == 3 ? filters.createdBetween : filters.etaBetween
            cell.setIsCellSelected(filter != nil)
            return cell.intrinsicContentSize.height
        }
        return 44
    }
    
    private func configureFilterCell(with tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DatesBetweenCell.identifier, for: indexPath) as! DatesBetweenCell
            cell.configureTitle("Created Between")
            if let createdBetween = filters.createdBetween {
                cell.setIsCellSelected(true)
                cell.configureDefaultDateFor(fromDate: createdBetween.start)
                cell.configureDefaultDateFor(toDate: createdBetween.end)
                cell.toDatePicker.maximumDate = Date()
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
                return configureFilterCell(with: tableView, for: indexPath)
            case 1:
                return configureResetToDefaultCell(with: tableView)
            default:
                fatalError()
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            handleDidSelectRowForFilterSection(with: indexPath)
        } else if indexPath.section == 1 {
            filters = Filters(assignedTo: SessionManager.shared.signedInUser?.userID)
            tableView.reloadData()
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
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if indexPath.row == 0 {
            selectUserForAssignedTo = true
            let vc = SelectUserVC(team: team, selectedUser: DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.assignedTo }))
            vc.selectionDelegate = self
            vc.canClearSelection = true
            vc.selectedUser = assignedToUser
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 1 {
            selectUserForAssignedTo = false
            let vc = SelectUserVC(team: team, selectedUser: DataManager.shared.getUserMatching({ $0.userID != nil && $0.userID == filters.assignedTo }))
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
    
}

extension FiltersVC: MemberSelectionDelegate {
    func selected(user: User) {
        if selectUserForAssignedTo {
            filters.assignedTo = user.userID
        } else {
            filters.createdBy = user.userID
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0) ], with: .none)
        navigationController?.popViewController(animated: true)
    }
    
    func clearedSelection() {
        if selectUserForAssignedTo {
            filters.assignedTo = nil
        } else {
            filters.createdBy = nil
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0) ], with: .none)
        navigationController?.popViewController(animated: true)
    }
}

extension FiltersVC: TaskStatusPickerDelegate {
    func selectedStatus(_ status: TaskStatus, dismiss: Bool) {
        filters.taskStatus = status
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        if dismiss {
            self.dismiss(animated: true)
        }
    }
    
    
}
