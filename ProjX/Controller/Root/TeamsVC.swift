//
//  TeamsVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TeamsVC: PROJXTableViewController {
 
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    lazy var currentTeamID: String? = nil
    lazy var searchString: String? = nil

    lazy var noDataTableBackgroundView: UILabel = {

        let title = NSMutableAttributedString(string: "Don't see anything here?\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        let desc = NSMutableAttributedString(string: "Press the + to create / join a team", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ])

        title.append(desc)

        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.attributedText = title
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        return noDataTitleLabel
    }()
    
    lazy var noSearchResultBackgroundView: UILabel = {
        let title = NSMutableAttributedString(string: "No search results!\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        let desc = NSMutableAttributedString(string: "Cannot find anything matching your search", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ])
        
        title.append(desc)
        
        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.attributedText = title
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center
        return noDataTitleLabel
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

    struct SectionData {
        var sectionHeader: String
        var rows: [Team]
    }

    lazy var dataSource: [SectionData] = []

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
        NotificationCenter.default.addObserver(self, selector: #selector(updateTeamTheme), name: Notification.Name("ThemeChanged"), object: nil)
    }

    @objc private func updateTeamTheme() {
        configureDatasource()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureRightBarButtonItems()
        configureDatasource()
        configureNotifCenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDatasource()
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataSource = []
    }
    
    private func configureUI() {
        title = "Teams"
        navigationItem.searchController = searchController
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamsTableViewCell")
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        tableView.backgroundView = noDataTableBackgroundView
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureRightBarButtonItems() {
        let newAction = UIAction(title: "Create Team") { [weak self] _ in
            let createTeamVc = CreateEditTeamVC()
            createTeamVc.delegate = self
            let nav = UINavigationController(rootViewController: createTeamVc)
            nav.modalPresentationStyle = .formSheet
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return 350 }), .large()]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
            }
            self?.present(nav, animated: true)
        }
        
        let joinAction = UIAction(title: "Join Team") { [weak self] _ in
            let joinVC = JoinTeamVC()
            joinVC.delegate = self
            let nav = UINavigationController(rootViewController: joinVC)
            nav.modalPresentationStyle = .formSheet
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return 300 }), .large()]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
            }
            self?.present(nav, animated: true)
        }
        
        let menu = UIMenu(children: [newAction, joinAction])

        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
    }

    private func configureDatasource() {
        dataSource = []
        showNoDataBackgroundView(false)
        let userTeams = SessionManager.shared.signedInUser?.teams.filter({ searchString == nil ? true : Util.findRange(of: searchString!.lowercased(), in: $0.teamName!) != nil })
        guard let userTeams = userTeams else { return }
        
        if let currentTeam = userTeams.first(where: { $0.teamID != nil && $0.teamID == SessionManager.shared.signedInUser?.selectedTeamID }) {
            currentTeamID = currentTeam.teamID?.uuidString
            dataSource.append(SectionData(sectionHeader: "Current Team", rows: [currentTeam]))
        }
        let otherTeams = userTeams.filter({ $0.teamID != nil && $0.teamID != SessionManager.shared.signedInUser?.selectedTeamID })
            .sorted(by: { $0.teamName! < $1.teamName! })
        if !otherTeams.isEmpty {
            dataSource.append(SectionData(sectionHeader: "Your Teams", rows: otherTeams))
        }
        
        guard !dataSource.isEmpty else {
            showNoDataBackgroundView(true)
            return
        }

    }
    
    private func showNoDataBackgroundView(_ state: Bool) {
        if state {
            tableView.backgroundView = noDataTableBackgroundView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func showSearchResultBackgroundView(_ state: Bool) {
        if state {
            tableView.backgroundView = noSearchResultBackgroundView
        } else {
            tableView.backgroundView = nil
        }
    }

    private func createTeamInfoVC(for team: Team) -> TeamInfoVC {
        let teamInfo = TeamInfoVC(team: team)
        teamInfo.delegate = self
        return teamInfo
    }

    @objc private func searchButtonOnClick() {
        navigationItem.titleView = searchController.searchBar
//        searchController.searchBar.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].sectionHeader
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
        Util.configureCustomSelectionStyle(for: cell)
        cell.accessoryType = .disclosureIndicator
        cell.cellImageView.contentMode = .scaleAspectFill
        let team = dataSource[indexPath.section].rows[indexPath.row]
        let teamName = team.teamName ?? "---"
        let nsRange = searchString != nil ? Util.findRange(of: searchString!, in: teamName) : nil
        cell.setTitle(teamName ,withHighLightRange: nsRange)
        cell.setImage(image: team.getTeamIcon(reduceTo: CGSize(width: 30, height: 30)))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let team = dataSource[indexPath.section].rows[indexPath.row]
        navigationController?.pushViewController(createTeamInfoVC(for: team), animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let team = dataSource[indexPath.section].rows[indexPath.row]
        let menuElement = UIDeferredMenuElement.uncached { [weak self] completion in
            var children: [UIMenuElement] = []
            
            if !team.isSelected {
                children.append(UIAction(title: "Set as Current Team", image: UIImage(systemName: "checkmark.circle"), attributes: team.isSelected ? [.disabled] : []) { [weak self] _ in
                    guard let self = self else { return }
                    DataManager.shared.changeSelectedTeam(of: SessionManager.shared.signedInUser!, to: team)
                    
                    let oldSelectedID = self.currentTeamID
                    let oldDataCount = dataSource.count
                    configureDatasource()
                    if dataSource.count < 2 {
                        tableView.reloadData()
                        return
                    }
                    if oldDataCount < 2 && dataSource.count == 2 {
                        tableView.performBatchUpdates({
                            tableView.insertSections(IndexSet(integer: 0), with: .right)
                            self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                        })
                    }
                    guard let oldSelectedID = oldSelectedID else {
                        self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                        return
                    }
                    let moveCurrentIndex = dataSource[1].rows.firstIndex(where: { $0.teamID?.uuidString == oldSelectedID })
                    guard let moveCurrentIndex = moveCurrentIndex else {
                        tableView.reloadData()
                        return
                    }
                    let moveCurrentToIndexPath = IndexPath(row: moveCurrentIndex, section: 1)

                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .left)
                        tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                        tableView.insertRows(at: [moveCurrentToIndexPath], with: .right)
                    })
                })
            }
            
            if SessionManager.shared.signedInUser!.isOwner(team) {
                children.append(UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
                    let createTeamVc = CreateEditTeamVC()
                    createTeamVc.delegate = self
                    createTeamVc.configureViewForEditing(team: team)
                    let nav = UINavigationController(rootViewController: createTeamVc)
                    nav.modalPresentationStyle = .formSheet
                    if let sheet = nav.sheetPresentationController {
                        sheet.detents = [.custom(resolver: { _ in return 350 }), .large()]
                        sheet.preferredCornerRadius = 20
                        sheet.prefersGrabberVisible = true
                    }
                    self?.present(nav, animated: true)
                })
            }
            
            let exitTitle = SessionManager.shared.signedInUser!.isOwner(team) ? "Delete" : "Leave"
            let exitImage = SessionManager.shared.signedInUser!.isOwner(team) ? UIImage(systemName: "trash") : UIImage(systemName: "rectangle.portrait.and.arrow.right")
            children.append(UIAction(title: exitTitle, image: exitImage, attributes: .destructive) { _ in
                if let signedInUserID = SessionManager.shared.signedInUser?.userID, team.teamOwnerID == signedInUserID {
                    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete team '\(team.teamName!)'", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                        let deleteCurrentIndex = self?.dataSource[team.isSelected ? 0 : 1].rows.firstIndex(where: { $0.teamID!.uuidString == team.teamID!.uuidString })
                        guard let deleteCurrentIndex = deleteCurrentIndex else {
                            tableView.reloadData()
                            return
                        }
                        let section = team.isSelected ? 0 : 1
                        let indexPath = IndexPath(row: deleteCurrentIndex, section: section)
                        DataManager.shared.deleteTeam(team)
                        let totalSections = self?.dataSource.count
                        self?.configureDatasource()
                        if totalSections != self?.dataSource.count {
                            self?.tableView.deleteSections(IndexSet(integer: section), with: .left)
                        } else {
                            self?.tableView.deleteRows(at: [indexPath], with: .left)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(alert, animated: true)
                } else {
                    if let deletingUser = SessionManager.shared.signedInUser, deletingUser.hasPendingTasks(in: team) {
                        let vc = ReassignTeamTasksVC(team: team, deletingUser: deletingUser)
                        vc.reloadDelegate = self
                        vc.isLeavingTeam = true
                        let nav = UINavigationController(rootViewController: vc)
                        self?.present(nav, animated: true)
                        return
                    }
                    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(team.teamName!)'", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
                        guard self != nil else { return }
                        let deleteCurrentIndex = self?.dataSource[team.isSelected ? 0 : 1].rows.firstIndex(where: { $0.teamID!.uuidString == team.teamID!.uuidString })
                        guard let deleteCurrentIndex = deleteCurrentIndex else {
                            tableView.reloadData()
                            return
                        }
                        let section = team.isSelected ? 0 : 1
                        let indexPath = IndexPath(row: deleteCurrentIndex, section: team.isSelected ? 0 : 1)
                        SessionManager.shared.signedInUser?.leave(team: team)
                        let totalSections = self?.dataSource.count
                        self?.configureDatasource()
                        if totalSections != self?.dataSource.count {
                            self?.tableView.deleteSections(IndexSet(integer: section), with: .left)
                        } else {
                            self?.tableView.deleteRows(at: [indexPath], with: .left)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(alert, animated: true)
                }
            })
            
            DispatchQueue.main.async {
                completion(children)
            }
        }
                
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            let previewViewController = TeamPreviewVC()
            previewViewController.configureView(for: team)
            previewViewController.preferredContentSize = CGSize(width: tableView.frame.width, height: 250)
            return previewViewController
        }, actionProvider: { _ in
            return UIMenu(children: [menuElement])
        })
        

    }

    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        let team = dataSource[indexPath.section].rows[indexPath.row]
        let vc = createTeamInfoVC(for: team)
        animator.preferredCommitStyle = .pop
        animator.addAnimations { [weak self] in
            self?.navigationController?.pushViewController(vc, animated: false)
        }
    }


}

extension TeamsVC: JoinTeamDelegate, CreateEditTeamDelegate, TeamExitDelegate {

    private func dismissAndDisplayInfo(of team: Team) {
        dismiss(animated: true) { [weak self] in
            self?.configureDatasource()
            self?.tableView.reloadData()
            let vc = self?.createTeamInfoVC(for: team)
            guard let vc = vc else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func joined(_ team: Team) {
        dismissAndDisplayInfo(of: team)
    }

    func changesSaved(_ team: Team) {
        dismissAndDisplayInfo(of: team)
    }

    func teamExited() {
        navigationController?.popViewController(animated: true)
    }

}

extension TeamsVC: UISearchBarDelegate, UISearchControllerDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        showSearchResultBackgroundView(false)
        if searchText.isEmpty {
            searchString = nil
            configureDatasource()
        } else {
            searchString = searchText.lowercased()
            configureDatasource()
            showSearchResultBackgroundView(dataSource.isEmpty)
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.titleView = nil
        searchString = nil
        showSearchResultBackgroundView(false)
        configureDatasource()
        tableView.reloadData()
    }
}

extension TeamsVC: ReloadDelegate {
    func reloadData() {
        configureDatasource()
        tableView.reloadData()
    }
}
