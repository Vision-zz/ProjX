//
//  PasswordUsernameVC.swift
//  ProjX
//
//  Created by Sathya on 27/04/23.
//

import UIKit

class PasswordUsernameVC: PROJXTableViewController {

    lazy var user: User! = nil

    private lazy var someValueChanged = false {
        didSet {
            if someValueChanged == true {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked))
            }
        }
    }

    private lazy var username = user.username

    private lazy var usernameTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = username
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .emailAddress
        tv.addTarget(self, action: #selector(usernameTextEdited), for: .editingChanged)
        return tv
    }()

    convenience init(user: User) {
        self.init(style: .insetGrouped)
        self.user = user
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
        title = "Account & Password"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NameEmailCell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
    }

    @objc private func cancelButtonClicked() {
//        guard someValueChanged else {
//            dismiss(animated: true)
//            return
//        }
//        let alert = UIAlertController(title: "Unsaved Changes", message: "You have unsaved changes. Do you want to save them before leaving?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Save Changes", style: .default) { [weak self] _ in
//            self?.doneButtonClicked()
//        })
//        alert.addAction(UIAlertAction(title: "Discard Changes", style: .default) { [weak self] _ in
//            self?.dismiss(animated: true)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        dismiss(animated: true)
    }

    @objc private func usernameTextEdited() {
        someValueChanged = true
        username = usernameTextField.text
    }

    @objc private func doneButtonClicked() {
        guard let username = username, !username.isEmpty else {
            showErrorAlert(title: "Empty Username", message: "Username cannot be empty")
            return
        }
        guard InputValidator.validate(username: username) else {
            showErrorAlert(title: "Invalid Username", message: "Usernames can only contain lowercase alphabets and underscores")
            return
        }
        saveChanges()
    }

    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }


    private func saveChanges() {
        user.username = username
        DataManager.shared.saveContext()
        self.dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Username"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Your username can be used to sign in to ProjX application"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func configureUsernameCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(usernameTextField)
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            usernameTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
        ])
        return cell
    }

    func configureChangePasswordCell() -> UITableViewCell{
        let cell = UITableViewCell()
        var config = cell.defaultContentConfiguration()
        config.text = "Change Password"
        config.textProperties.color = .systemBlue
        cell.contentConfiguration = config
        return cell
    }

    func configureAccountOverviewCell(for indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell()
        let keyValue: [(key:String, value:String)] = [
            ("Created At", SessionManager.shared.signedInUser!.createdAt!.convertToString()),
            ("Last Password update", SessionManager.shared.signedInUser!.passLastUpdate!.convertToString()),
        ]

        var config = cell.defaultContentConfiguration()
        config.text = keyValue[indexPath.row].key
        config.secondaryText = keyValue[indexPath.row].value
        config.prefersSideBySideTextAndSecondaryText = true

        config.imageProperties.tintColor = .label
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .label

        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureUsernameCell()
        } else if indexPath.section == 1 {
            return configureChangePasswordCell()
        } else if indexPath.section == 2 {
            return configureAccountOverviewCell(for: indexPath)
        }
        fatalError()
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        let vc = ChangePasswordVC()
        vc.passwordChangeDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension PasswordUsernameVC: PasswordUpdateDelegate {
    func passwordChanged(to newPassword: String) {
        user.password = newPassword
        DataManager.shared.saveContext()
        navigationController?.popViewController(animated: true)
    }
}
