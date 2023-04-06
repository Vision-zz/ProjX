    //
    //  SigninVC.swift
    //  ProjX
    //
    //  Created by Sathya on 17/03/23.
    //

import UIKit

class SigninVC: BaseLoginViewTableView {
#if DEBUG
    deinit {
        print("Deinit SigninVC")
    }
#endif
    
    weak var signInDelegate: SignInDelegate? = nil

    lazy var footerViews =  [
        0: usernameErrorLabel,
        1: passwordErrorLabel
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = "Sign In"
        passwordTextField.returnKeyType = .go
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignInCell")
        usernameTextField.addTarget(self, action: #selector(usernameTextEdited), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextEdited), for: .editingChanged)
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @objc func signUpSwitchButtonPressed() {
        signInDelegate?.signUpSwitchButtonPressed()
    }

    @objc func loginButtonOnClick() {
        resetErrorLabel(usernameErrorLabel)
        resetErrorLabel(passwordErrorLabel)
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

        guard InputValidator.validate(username: username) else {
            usernameErrorLabel.text = "Invalid characters in username"
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
        resetErrorLabel(usernameErrorLabel)
        guard let text = usernameTextField.text else { return }
        if !InputValidator.validate(username: text) {
            usernameErrorLabel.text = "Invalid characters in username"
        }
    }

    @objc private func passwordTextEdited() {
        resetErrorLabel(passwordErrorLabel)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerViews[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignInCell", for: indexPath)

        cell.backgroundColor = .clear

        if indexPath.section == 2 {
            configureCellForLoginButton(cell, title: "Sign In", selector: #selector(loginButtonOnClick))
        } else if indexPath.section == 3 {
            configureCellForLoginTypeSwitch(cell, buttonSelector: #selector(signUpSwitchButtonPressed), labelText: "Don't have an account?", buttonTitle: "Sign Up")
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

extension SigninVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case usernameTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                fallthrough
            default:
                loginButtonOnClick()
                textField.resignFirstResponder()
        }
        return false
    }

}
