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

        configureUI()
    }

    private func configureUI() {
        title = "Sign In"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignInCell")
        tableView.delegate = self
        tableView.dataSource = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @objc func signUpButtonPressed() {
        signInDelegate?.signUpButtonPressed()
    }

    @objc func signInButtonOnClick() {
        var isEmpty = false
        if usernameTextField.text == nil || usernameTextField.text!.isEmpty {
            isEmpty = true
            usernameDetailLabel.text = "This is a required field*"
        }

        if passwordTextField.text == nil || passwordTextField.text!.isEmpty {
            isEmpty = true
            passwordDetailLabel.text = "This is a required field*"
        }

        guard !isEmpty else { return }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? usernameDetailLabel : section == 1 ? passwordDetailLabel : nil
    }

    private func configureCellForLoginButton(_ cell: UITableViewCell) {
        loginButton.addTarget(self, action: #selector(signInButtonOnClick), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)

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

        cell.backgroundColor = Constants.Background.getColor(for: .primary)

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

extension SigninVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text ?? "nil")
        print(textField.tag)
        if textField.text != nil && textField.text == "Hello" {
            signUpButtonPressed()
        }
        return true
    }

}
