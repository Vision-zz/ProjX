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

    lazy var noDataStack: UIStackView = {

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label,
        ]

        let descAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let title = NSMutableAttributedString(string: "Dont' see anthing here?\n", attributes: titleAttributes)
        let desc = NSMutableAttributedString(string: "Press the + to create / join a team", attributes: descAttributes)
        title.append(desc)

        let noDataTitleLabel = UILabel()
        noDataTitleLabel.textColor = .label
        noDataTitleLabel.attributedText = title
        noDataTitleLabel.numberOfLines = 0
        noDataTitleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [noDataTitleLabel])
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    struct SectionData {
        var section: Int
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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureDatasource()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDatasource()
        tableView.reloadData()
    }

    private func configureUI() {
        title = "Team"

        let newAction = UIAction(title: "Create Team") { _ in
            let createTeamVc = CreateTeamVC()
            createTeamVc.delegate = self
            self.navigationController?.present(createTeamVc, animated: true)
        }

        let joinAction = UIAction(title: "Join Team") { [weak self] _ in
            let joinVC = JoinTeamVC()
            joinVC.delegate = self
            self?.navigationController?.present(UINavigationController(rootViewController: joinVC), animated: true)
        }
        let menu = UIMenu(children: [newAction, joinAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
    }

    private func configureTableView() {
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: "TeamsTableViewCell")
        tableView.backgroundView = noDataStack
    }

    private func configureDatasource() {
        dataSource.removeAll()
        noDataStack.isHidden = true
        let userTeams = SessionManager.shared.signedInUser?.teams
        guard let userTeams = userTeams else { return }
        let currentTeam = userTeams.first(where: { $0.teamID != nil && $0.teamID == SessionManager.shared.signedInUser?.selectedTeamID })
        currentTeamID = currentTeam?.teamID?.uuidString
        let otherTeams = userTeams.filter({ $0.teamID != nil && $0.teamID != SessionManager.shared.signedInUser?.selectedTeamID })
        if currentTeam == nil && otherTeams.isEmpty {
            noDataStack.isHidden = false
            return
        }
        dataSource.append(SectionData(section: 0, sectionHeader: "Current Team", rows: currentTeam != nil ? [currentTeam!] : []))
        dataSource.append(SectionData(section: 1, sectionHeader: "Your Teams", rows: otherTeams))
    }

    private func createTeamInfoVC(for team: Team) -> TeamInfoVC {
        let teamInfo = TeamInfoVC(team: team)
        teamInfo.delegate = self
        return teamInfo
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamsTableViewCell", for: indexPath) as! TeamTableViewCell
        cell.configureCellData(teamIcon: dataSource[indexPath.section].rows[indexPath.row].teamIconImage, teamName: dataSource[indexPath.section].rows[indexPath.row].teamName ?? "")
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

}

extension TeamsVC: JoinTeamDelegate, CreateTeamDelegate, TeamExitDelegate {

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

    func created(_ team: Team) {
        dismissAndDisplayInfo(of: team)
    }

    func teamExited() {
        navigationController?.popViewController(animated: true)
    }

}
