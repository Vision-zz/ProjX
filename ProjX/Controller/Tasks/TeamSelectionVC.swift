//
//  TeamSelectionVC.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class TeamSelectionVC: PROJXTableViewController {
    
    weak var teamSelectDelegate: TeamSelectDelegate? = nil
    
    var dataSource = [Team]()
    var selectedTeam: Team? = nil
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDatasource()
    }
    
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
        print("Deinit Team selection")
    }
    
    private func configureView() {
        title = "Select Team"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonOnClick))
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func configureDatasource() {
        selectedTeam = SessionManager.shared.signedInUser?.selectedTeam
        dataSource = SessionManager.shared.signedInUser?.teams.sorted(by: { $0.teamName! < $1.teamName! }) ?? []
    }
    
    @objc private func closeButtonOnClick() {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PROJXImageTextCell.identifier, for: indexPath) as! PROJXImageTextCell
        Util.configureCustomSelectionStyle(for: cell)
        let team = dataSource[indexPath.row]
        cell.accessoryType = SessionManager.shared.signedInUser?.selectedTeamID == team.teamID && team.teamID != nil ? .checkmark : .none
        cell.cellImageView.contentMode = .scaleAspectFill
        cell.configureCellData(text: team.teamName ?? "---", image: team.getTeamIcon(reduceTo: CGSize(width: 30, height: 30)))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = dataSource[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        teamSelectDelegate?.teamSelected(team: team)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let team = dataSource[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            let previewViewController = TeamPreviewVC()
            previewViewController.configureView(for: team)
            previewViewController.preferredContentSize = CGSize(width: tableView.frame.width, height: 250)
            return previewViewController
        })
    }

}


extension TeamSelectionVC: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            configureDatasource()
        } else {
            let userTeams = SessionManager.shared.signedInUser?.teams
            guard let userTeams = userTeams else { return }
            dataSource = userTeams.filter({ $0.teamName!.lowercased().starts(with: searchText.lowercased()) })
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        configureDatasource()
        tableView.reloadData()
    }
}
