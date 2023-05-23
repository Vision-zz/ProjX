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
    lazy var searchString: String? = nil
    
    lazy var noDataTableBackgroundView: UILabel = {
        
        let title = NSMutableAttributedString(string: "Don't see anything here?\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ])
        let desc = NSMutableAttributedString(string: "Head over to teams tab to get yourself into a team", attributes: [
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
//        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.returnKeyType = .search
        search.searchBar.insetsLayoutMarginsFromSafeArea = true
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
        navigationController?.additionalSafeAreaInsets.top = 7.5
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonOnClick))
        tableView.register(PROJXImageTextCell.self, forCellReuseIdentifier: PROJXImageTextCell.identifier)
        navigationItem.searchController = searchController
    }

    private func configureDatasource() {
        showNoDataBackgroundView(false)
        selectedTeam = SessionManager.shared.signedInUser?.selectedTeam
        dataSource = SessionManager.shared.signedInUser?.teams
            .filter({ searchString == nil ? true : Util.findRange(of: searchString!.lowercased(), in: $0.teamName!) != nil })
            .sorted(by: { $0.teamName! < $1.teamName! }) ?? []
        
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
        let teamName = team.teamName ?? "---"
        let nsRange = searchString != nil ? Util.findRange(of: searchString!, in: teamName) : nil
        cell.setTitle(teamName ,withHighLightRange: nsRange)
        cell.setImage(image: team.getTeamIcon(reduceTo: CGSize(width: 30, height: 30)))
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
        searchString = nil
        showSearchResultBackgroundView(false)
        configureDatasource()
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
