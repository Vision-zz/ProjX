    //
    //  LoginVC.swift
    //  ProjX
    //
    //  Created by Sathya on 17/03/23.
    //

import UIKit

class SignupVC: BaseLoginViewTableView {

    weak var signUpDelegate: SignUpDelegate? = nil

    lazy var confirmPasswordTextField: UITextField = {
        let textField = createTextField(placeholder: "Confirm Password*")
        textField.isSecureTextEntry = true
        textField.enablePasswordToggle()
        textField.textContentType = .oneTimeCode
        return textField
    }()

    lazy var displayNameTextField = createTextField(placeholder: "Display name")
    lazy var emailTextField = createTextField(placeholder: "Email*")

    lazy var passwordStrengthBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progressTintColor = .systemRed
        bar.trackTintColor = .white
        bar.layer.masksToBounds = true
        bar.clipsToBounds = true
        bar.backgroundColor = .white
        bar.layer.cornerRadius = 2
        bar.isHidden = true
        return bar
    }()

    lazy var confirmPasswordErrorLabel = createErrorLabel()
    lazy var emailErrorLabel = createErrorLabel()

    lazy var footerViews: [Int: UIView] = [
        0: usernameErrorLabel,
        2: emailErrorLabel,
        3: passwordErrorLabel,
        4: confirmPasswordErrorLabel,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    @objc func signInSwitchButtonPressed() {
        signUpDelegate?.signInSwitchButtonPressed()
    }

    @objc func signUpButtonOnClick() {

        resetErrorLabel(usernameErrorLabel)
        resetErrorLabel(passwordErrorLabel)

        let username = usernameTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        let displayName = displayNameTextField.text
        let email = emailTextField.text

        guard let username = username, !username.isEmpty,
              let password = password,  !password.isEmpty,
              let confirmPassword = confirmPassword, !confirmPassword.isEmpty,
              let displayName = displayName, !displayName.isEmpty,
              let email = email, !email.isEmpty
        else {
            let requiredFieldString = "This is a required field*"
            if username == nil || username!.isEmpty {
                usernameErrorLabel.text = requiredFieldString
            }
            if password == nil || passwordTextField.text!.isEmpty {
                passwordErrorLabel.text = requiredFieldString
            }
            if confirmPassword == nil || confirmPassword!.isEmpty {
                confirmPasswordErrorLabel.text = requiredFieldString
            }
            if email == nil || email!.isEmpty {
                emailErrorLabel.text = requiredFieldString
            }
            return
        }

        if !InputValidator.validate(username: username) {
            usernameErrorLabel.text = "Invalid characters in username"
            return
        }

        if password != confirmPassword {
            confirmPasswordErrorLabel.text = "Passwords don't match"
            return
        }

        if !InputValidator.validate(email: email) {
            emailErrorLabel.text = "Invalid Email address"
            return
        }

        let authenticationStatus = DataManager.shared.createUser(username: username, password: password, name: displayName, emailID: email)

        switch authenticationStatus {
            case .failure(let status):
                usernameErrorLabel.text = status.rawValue
                return
            case .success(let user):
                signUpDelegate?.successfulRegister(user: user)
        }
    }

    func configureView() {
        title = "Sign Up"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignUpCell")
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldEdited), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldEdited), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldEdited), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailTextFieldEdited), for: .editingChanged)
        navigationItem.largeTitleDisplayMode = .always

    }

    @objc private func usernameTextFieldEdited() {
        resetErrorLabel(usernameErrorLabel)
        guard let text = usernameTextField.text else { return }
        if !InputValidator.validate(username: text) {
            usernameErrorLabel.text = "Invalid characters in username"
        }
    }

    @objc private func passwordTextFieldEdited() {
        resetErrorLabel(passwordErrorLabel)
        guard let password = passwordTextField.text, !password.isEmpty else {
            setProgress(progress: 0.001)
            return
        }
        setProgress(progress: InputValidator.calculatePasswordComplexityPercentage(password))
    }

    @objc private func confirmPasswordTextFieldEdited() {
        resetErrorLabel(confirmPasswordErrorLabel)
    }

    @objc private func emailTextFieldEdited() {
        resetErrorLabel(emailErrorLabel)
        guard let text = emailTextField.text else { return }
        if !InputValidator.validate(email: text) {
            emailErrorLabel.text = "Invalid Email address"
        }
    }

    private func setProgress(progress: Double) {
        passwordStrengthBar.isHidden = false
        passwordStrengthBar.setProgress(Float(progress / 100), animated: true)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            if progress > 0 {
                self?.passwordStrengthBar.progressTintColor = .systemRed
            }
            if progress > 25 {
                self?.passwordStrengthBar.progressTintColor = .systemOrange
            }
            if progress > 50 {
                self?.passwordStrengthBar.progressTintColor = .systemYellow
            }
            if progress > 75 {
                self?.passwordStrengthBar.progressTintColor = .systemGreen
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        7
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerViews[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SignUpCell", for: indexPath)
        cell.backgroundColor = .clear
        var textFieldToAdd: UITextField? = nil
        switch indexPath.section {
            case 0:
                textFieldToAdd = usernameTextField
            case 1:
                textFieldToAdd = displayNameTextField
            case 2:
                textFieldToAdd = emailTextField
            case 3:
                textFieldToAdd = passwordTextField
            case 4:
                textFieldToAdd = confirmPasswordTextField
            case 5:
                configureCellForLoginButton(cell, title: "Sign Up", selector: #selector(signUpButtonOnClick))
            case 6:
                configureCellForLoginTypeSwitch(cell, buttonSelector: #selector(signInSwitchButtonPressed), labelText: "Already have an account?", buttonTitle: "Sign In")
            default:
                return cell
        }

        if let textFieldToAdd = textFieldToAdd, [0,1,2,3,4].contains(indexPath.section){
            cell.contentView.addSubview(textFieldToAdd)

            NSLayoutConstraint.activate([
                textFieldToAdd.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textFieldToAdd.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                textFieldToAdd.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                textFieldToAdd.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            ])

            if indexPath.section == 3 {
                cell.contentView.addSubview(passwordStrengthBar)

                NSLayoutConstraint.activate([
                    passwordStrengthBar.topAnchor.constraint(equalTo: textFieldToAdd.bottomAnchor, constant: 2),
                    passwordStrengthBar.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                    passwordStrengthBar.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                    passwordStrengthBar.heightAnchor.constraint(equalToConstant: 4)
                ])
            }

        }


        return cell
    }

}
