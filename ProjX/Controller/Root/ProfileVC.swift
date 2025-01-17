//
//  ProfileVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class ProfileVC: PROJXTableViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["System", "Light", "Dark"])
        segmentControl.selectedSegmentIndex = GlobalConstants.Device.selectedTheme.rawValue
        segmentControl.addTarget(self, action: #selector(segmentControlValueChange), for: .valueChanged)
        segmentControl.selectedSegmentTintColor = GlobalConstants.Colors.accentColor
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segmentControl
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNotifCenter()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureNotifCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: Notification.Name("ThemeChanged"), object: nil)
    }

    @objc private func updateTheme() {
        tableView.reloadSections(IndexSet(arrayLiteral: 0, 1, 3), with: .none)
        segmentControl.selectedSegmentTintColor = GlobalConstants.Colors.accentColor
    }

    private func configureView() {
        title = "Profile"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileKeyValueCell")
        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        tableView.register(AccentColorSelectionCell.self, forCellReuseIdentifier: AccentColorSelectionCell.identifier)
    }


    @objc private func logoutButtonOnClick() {
        SessionManager.shared.logout()
    }

    @objc private func segmentControlValueChange(_ segmentControl: UISegmentedControl) {
        let selectedTheme = GlobalConstants.Device.SelectedTheme.init(rawValue: segmentControl.selectedSegmentIndex)!
        DataManager.shared.setSelectedTheme(selectedTheme)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        }
        return 44
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 2
            case 2:
                return 2
            case 3:
                return 2
            default:
                return 0
        }
    }

    func configureAccountSettingsCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let cellString = ["Name, Profile Image, Email", "Account & Password"]

        var config = cell.defaultContentConfiguration()
        config.text = cellString[indexPath.row]
        config.textProperties.color = .label
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
    }

    private func configureThemeSelectionCell(_ cell: UITableViewCell) {
        var config = cell.defaultContentConfiguration()
        config.text = "Theme"
        config.textProperties.color = .label
        cell.contentConfiguration = config
        cell.accessoryView = segmentControl
    }

    private func configureAccentColorCell(_ cell: AccentColorSelectionCell) {
        cell.backgroundColor = .red
    }

    private func configureLogoutCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        var config = cell.defaultContentConfiguration()
        config.textProperties.color = .systemRed
        config.imageProperties.tintColor = .systemRed
        if indexPath.row == 0 {
            config.text = "Logout"
            config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        } else {
            config.text = "Delete my Account"
            config.image = UIImage(systemName: "trash")
        }
        cell.accessoryType = .none
        cell.contentConfiguration = config
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
                cell.selectionStyle = .none
                cell.configure(with: SessionManager.shared.signedInUser!)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileKeyValueCell", for: indexPath)
                Util.configureCustomSelectionStyle(for: cell)
                configureAccountSettingsCell(cell, indexPath: indexPath)
                return cell
            case 2:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileKeyValueCell", for: indexPath)
                    cell.selectionStyle = .none
                    configureThemeSelectionCell(cell)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: AccentColorSelectionCell.identifier, for: indexPath) as! AccentColorSelectionCell
                    cell.selectionStyle = .none
                    return cell
                }
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileKeyValueCell", for: indexPath)
                Util.configureCustomSelectionStyle(for: cell, with: .systemRed)
                configureLogoutCell(cell, indexPath: indexPath)
                return cell
            default:
                fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Edit Account"
        } else if section == 2 {
            return "Appearance"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard [1, 3].contains(indexPath.section) else { return }
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Logout", message: "Do you want to log out?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in SessionManager.shared.logout() })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            } else {
                deleteAccount()
            }
        }

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = NameEmailVC(user: SessionManager.shared.signedInUser!)
                vc.profileUpdateDelegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .formSheet
                nav.navigationBar.tintColor = GlobalConstants.Colors.accentColor
                present(nav, animated: true)
            } else {
                let vc = PasswordUsernameVC(user: SessionManager.shared.signedInUser!)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .formSheet
                nav.navigationBar.tintColor = GlobalConstants.Colors.accentColor
                present(nav, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if [1, 3].contains(indexPath.section) {
            return indexPath
        }
        return nil
    }
}

extension ProfileVC {
    func deleteAccount() {
        guard let user = SessionManager.shared.signedInUser else { return }
        guard user.hasPendingTasks else {
            let alert = UIAlertController(title: "Are you sure?", message: "This action is not reversible and your account will be deleted permanently. Do you want to proceed?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Proceed", style: .destructive) { _ in
                DataManager.shared.deleteUser(username: SessionManager.shared.signedInUser!.username!)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let vc = ReassignTasksVC(deletingUser: user)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        
    }
}

extension ProfileVC: ProfileUpdateDelegate {
    func profileUpdated() {
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
}
