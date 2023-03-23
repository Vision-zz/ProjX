    //
    //  SigninVC.swift
    //  ProjX
    //
    //  Created by Sathya on 17/03/23.
    //

import UIKit

class SigninVC: BaseLoginViewTableViewTableViewController {

    var signInDelegate: SignInDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        title = "Sign In"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignInCell")
        usernameTextField.addTarget(self, action: #selector(usernameTextEdited), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextEdited), for: .editingChanged)
    }

    @objc func signUpSwitchButtonPressed() {
        signInDelegate?.signUpSwitchButtonPressed()
    }

    @objc func loginButtonOnClick() {
        resetUsernameErrorLabel()
        resetPasswordErrorLabel()
        let username = usernameTextField.text
        let password = passwordTextField.text
        guard let username = username, let password = password, !username.isEmpty, !password.isEmpty else {
            if username == nil || username!.isEmpty {
                usernameErrorLabel.text = "This is a required field*"
            }
            if passwordTextField.text == nil || passwordTextField.text!.isEmpty {
                passwordErrorLabel.text = "This is a required field*"
            }
            return
        }

        let authenticationStatus = SessionManager.shared.authenticate(username: username, password: password)

        switch authenticationStatus {
            case .failure(let failureReason):
                switch failureReason {
                    case .invalidPassowrd:
                        passwordErrorLabel.text = "Invalid password"
                    case .userNotFound:
                        usernameErrorLabel.text = "User not found"
                }
            case .success:
                signInDelegate?.successfulLogin()
        }

    }

    @objc private func usernameTextEdited() {
        resetUsernameErrorLabel()
        guard let text = usernameTextField.text else { return }
        if !InputValidator.validate(username: text) {
            usernameErrorLabel.text = "Invalid characters in username"
        }
    }

    @objc private func passwordTextEdited() {
        resetPasswordErrorLabel()
    }

    private func resetUsernameErrorLabel() {
        guard let text = usernameErrorLabel.text, !text.isEmpty else {
            return
        }
        usernameErrorLabel.text = ""
    }

    private func resetPasswordErrorLabel() {
        guard let text = passwordErrorLabel.text, !text.isEmpty else {
            return
        }
        passwordErrorLabel.text = ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? usernameErrorLabel : section == 1 ? passwordErrorLabel : nil
    }

    private func configureCellForLoginButton(_ cell: UITableViewCell) {
        loginButton.addTarget(self, action: #selector(loginButtonOnClick), for: .touchUpInside)
        cell.contentView.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 0.4),
            loginButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
    }

    private func configureCellForSignUpSwitch(_ cell: UITableViewCell) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Don't have an account?"
        label.textColor = .label
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.tintColor = .link
        button.addTarget(self, action: #selector(signUpSwitchButtonPressed), for: .touchUpInside)

        let customView = UIView()
        customView.translatesAutoresizingMaskIntoConstraints = false

        customView.addSubview(label)
        customView.addSubview(button)
        cell.contentView.addSubview(customView)

        NSLayoutConstraint.activate([

            label.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: customView.centerYAnchor),

            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            button.centerYAnchor.constraint(equalTo: customView.centerYAnchor),

            customView.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + button.intrinsicContentSize.width),
            customView.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor),
            customView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            customView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
        ])

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignInCell", for: indexPath)

        cell.backgroundColor = GlobalConstants.Background.getColor(for: .primary)

        if indexPath.section == 2 {
            configureCellForLoginButton(cell)
        } else if indexPath.section == 3 {
            configureCellForSignUpSwitch(cell)
        } else {
            let textFieldToAdd = indexPath.section == 0 ? usernameTextField : passwordTextField
            cell.contentView.addSubview(textFieldToAdd)

            NSLayoutConstraint.activate([
                textFieldToAdd.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textFieldToAdd.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                textFieldToAdd.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                textFieldToAdd.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            ])
        }
        return cell
    }
}
