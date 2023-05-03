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
        configureTableView()
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

        var items = [ UIBarButtonItem(systemItem: .add, menu: menu) ]
        if !GlobalConstants.Device.isIpad {
            items.append(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonOnClick)))
        }
        navigationItem.rightBarButtonItems = items
    }

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamsTableViewCell")
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        tableView.backgroundView = noDataTableBackgroundView
    }

    private func configureDatasource() {
        dataSource = []
        noDataTableBackgroundView.isHidden = true
        let userTeams = SessionManager.shared.signedInUser?.teams
        guard let userTeams = userTeams else { return }
        let currentTeam = userTeams.first(where: { $0.teamID != nil && $0.teamID == SessionManager.shared.signedInUser?.selectedTeamID })
        currentTeamID = currentTeam?.teamID?.uuidString
        let otherTeams = userTeams.filter({ $0.teamID != nil && $0.teamID != SessionManager.shared.signedInUser?.selectedTeamID })
        if currentTeam == nil && otherTeams.isEmpty {
            noDataTableBackgroundView.isHidden = false
            return
        }
        dataSource.append(SectionData(sectionHeader: "Current Team", rows: currentTeam != nil ? [currentTeam!] : []))
        dataSource.append(SectionData(sectionHeader: "Your Teams", rows: otherTeams))
        for i in 0..<dataSource.count {
            dataSource[i].rows.sort(by: { $0.teamName! < $1.teamName! })
        }
    }

    private func createTeamInfoVC(for team: Team) -> TeamInfoVC {
        let teamInfo = TeamInfoVC(team: team)
        teamInfo.delegate = self
        return teamInfo
    }

    @objc private func searchButtonOnClick() {
        searchController.searchBar.becomeFirstResponder()
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
        cell.configureCellData(text: dataSource[indexPath.section].rows[indexPath.row].teamName ?? "---", image: dataSource[indexPath.section].rows[indexPath.row].getTeamIcon(reduceTo: CGSize(width: 15, height: 15)))
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
                    guard let oldSelectedID = oldSelectedID else {
                        configureDatasource()
                        self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                        return
                    }
                    configureDatasource()
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
                        let indexPath = IndexPath(row: deleteCurrentIndex, section: team.isSelected ? 0 : 1)
                        DataManager.shared.deleteTeam(team)
                        self?.configureDatasource()
                        self?.tableView.deleteRows(at: [indexPath], with: .left)
                    }))
                    alert.addAction(UIAlertAction(title: "Go back", style: .cancel))
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(team.teamName!)'", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
                        guard self != nil else { return }
                        let deleteCurrentIndex = self?.dataSource[team.isSelected ? 0 : 1].rows.firstIndex(where: { $0.teamID!.uuidString == team.teamID!.uuidString })
                        guard let deleteCurrentIndex = deleteCurrentIndex else {
                            tableView.reloadData()
                            return
                        }
                        let indexPath = IndexPath(row: deleteCurrentIndex, section: team.isSelected ? 0 : 1)
                        SessionManager.shared.signedInUser?.leave(team: team)
                        self?.configureDatasource()
                        self?.tableView.deleteRows(at: [indexPath], with: .left)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(alert, animated: true)
                }
            })
            
            completion(children)
        }
                
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil, actionProvider: { _ in
            return UIMenu(children: [menuElement])
        })
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
//
//extension TeamsVC: TeamOptionsDelegate {
//    func teamSelectButtonPressed() {
//        tableView.reloadSections(IndexSet(integer: 0), with: .none)
//    }
//
//    func teamEditButtonPressed() {
//        let createTeamVc = CreateEditTeamVC()
//        createTeamVc.delegate = self
//        createTeamVc.configureViewForEditing(team: team)
//        let nav = UINavigationController(rootViewController: createTeamVc)
//        nav.modalPresentationStyle = .formSheet
//        if let sheet = nav.sheetPresentationController {
//            sheet.detents = [.custom(resolver: { _ in return 350 }), .large()]
//            sheet.preferredCornerRadius = 20
//            sheet.prefersGrabberVisible = true
//        }
//        self.present(nav, animated: true
//    }
//
//    func teamExitButtonPressed() {
//        if let signedInUserID = SessionManager.shared.signedInUser?.userID, self.team.teamOwnerID == signedInUserID {
//            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete team '\(self.team.teamName!)'", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
//                DataManager.shared.deleteTeam(self!.team)
//                self?.delegate?.teamExited()
//            }))
//            alert.addAction(UIAlertAction(title: "Go back", style: .cancel))
//            self.present(alert, animated: true)
//        } else {
//            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to leave team '\(self.team.teamName!)'", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
//                guard self != nil else { return }
//                SessionManager.shared.signedInUser?.leave(team: self!.team)
//                self?.delegate?.teamExited()
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            self.present(alert, animated: true)
//        }
//    }
//}

extension TeamsVC: UISearchBarDelegate, UISearchControllerDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            configureDatasource()
        } else {
            
            let userTeams = SessionManager.shared.signedInUser?.teams
            guard let userTeams = userTeams else { return }
            let currentTeam = userTeams.first(where: { $0.teamID != nil && $0.teamID == SessionManager.shared.signedInUser?.selectedTeamID })
            currentTeamID = currentTeam?.teamID?.uuidString
            let otherTeams = userTeams.filter({ $0.teamID != nil && $0.teamID != SessionManager.shared.signedInUser?.selectedTeamID })
            if currentTeam == nil && otherTeams.isEmpty {
                noDataTableBackgroundView.isHidden = false
                return
            }
            dataSource = []
            dataSource.append(SectionData(sectionHeader: "Current Team", rows: currentTeam != nil ? [currentTeam!].filter({ $0.teamName!.starts(with: searchText) }) : []))
            dataSource.append(SectionData(sectionHeader: "Your Teams", rows: otherTeams.filter({ $0.teamName!.starts(with: searchText) })))
            
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        configureDatasource()
        tableView.reloadData()
    }
}

