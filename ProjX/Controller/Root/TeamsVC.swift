//
//  TeamsVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class TeamsVC: ELDSTableViewController {

    lazy var dataSource: [Team] = []

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

    private func configureUI() {
        title = "Team"
    }

    private func configureTableView() {
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: "TeamsTableViewCell")
    }

    private func configureDatasource() {
        dataSource = SessionManager.shared.signedInUser?.teams ?? []
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamsTableViewCell", for: indexPath) as! TeamTableViewCell
        cell.configureCellData(teamIcon: dataSource[indexPath.row].teamIconImage, teamName: dataSource[indexPath.row].teamName ?? "")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

}
