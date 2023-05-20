//
//  StatusUpdatesVC.swift
//  ProjX
//
//  Created by Sathya on 15/05/23.
//

import UIKit

class StatusUpdatesVC: PROJXTableViewController {

    lazy var statusUpdates = [TaskStatusUpdate]()
    lazy var assignedUser: User! = nil
    lazy var expandedSection: Int? = nil
    let heightTestCell = StatusUpdateCell()
    
    lazy var noDataTableBackgroundView: UILabel = {
        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        
        let title = NSMutableAttributedString(string: "Can't find anything?\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        
        title.append(NSMutableAttributedString(string: "There are no status updates for this task", attributes: [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.secondaryLabel
        ]))
        
        noDataTitleLabel.attributedText = title
        
        return noDataTitleLabel
    }()
    
    convenience init(statusUpdates: [TaskStatusUpdate], assignedUser: User) {
        self.init(style: .insetGrouped)
        self.statusUpdates = statusUpdates
        self.assignedUser = assignedUser
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
        configureDatasource()
    }

    private func configureView() {
        title = "Status Updates"
        tableView.register(StatusUpdateCell.self, forCellReuseIdentifier: StatusUpdateCell.identifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "DummyHeader")
        tableView.backgroundView = noDataTableBackgroundView
        tableView.backgroundView?.isHidden = true
    }
    
    private func configureDatasource() {
        statusUpdates = statusUpdates.sorted(by: { $0.createdAt!.timeIntervalSince1970 > $1.createdAt!.timeIntervalSince1970 })
        if statusUpdates.isEmpty {
            tableView.backgroundView?.isHidden = false
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return statusUpdates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "DummyHeader")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightTestCell.configureCell(with: statusUpdates[indexPath.section])
        if let expandedIndexpath = expandedSection, expandedIndexpath == indexPath.section {
            heightTestCell.isCollapsed = false
        } else {
            heightTestCell.isCollapsed = true
        }
        return heightTestCell.cellHeight
//        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusUpdateCell.identifier, for: indexPath) as! StatusUpdateCell
        let task = statusUpdates[indexPath.section]
        cell.configureCell(with: task)
        cell.delegate = self
        cell.associatedIndexpath = indexPath
        cell.setCellIsCollapsed(indexPath.section != expandedSection)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let userID = SessionManager.shared.signedInUser?.userID, assignedUser.userID == userID, statusUpdates[indexPath.section].task?.taskStatus != .complete else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this Status update permanently?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { [unowned self] _ in
                DataManager.shared.deleteStatusUpdate(self.statusUpdates[indexPath.section])
                self.statusUpdates.remove(at: indexPath.section)
                self.configureDatasource()
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                completionHandler(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            self.present(alert, animated: true)
            
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

}

extension StatusUpdatesVC: StatusUpdateCollapseDelegate {
    func cellExpanded(atIndexPath indexPath: IndexPath) {
        var indexPaths = [indexPath]
        if let expandedSection = expandedSection, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: expandedSection)) as? StatusUpdateCell {
            cell.setCellIsCollapsed(true)
            indexPaths.append(IndexPath(row: 0, section: expandedSection))
        }
        expandedSection = indexPath.section
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func cellCollapsed(atIndexPath indexPath: IndexPath) {
        if let expandedSection = expandedSection,let _ = tableView.cellForRow(at: indexPath) as? StatusUpdateCell, indexPath.section == expandedSection {
            self.expandedSection = nil
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? StatusUpdateCell else { return }
        cell.toggleCellCollapse()
        return
    }
    
}
