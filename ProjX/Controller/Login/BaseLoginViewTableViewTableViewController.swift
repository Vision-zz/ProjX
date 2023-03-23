//
//  BaseLoginViewTableViewTableViewController.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import UIKit

class BaseLoginViewTableViewTableViewController: UITableViewController {

    lazy var usernameTextField: UITextField = {
        var textField = UITextField()
        textField.tag = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        return textField
    }()

    lazy var passwordTextField: UITextField = {
        var textField = UITextField()
        textField.tag = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.enablePasswordToggle()
        let passwordRuleDescriptor = "required: upper; required: lower; required: digit; required: special; minlength: 8;"
        textField.passwordRules = UITextInputPasswordRules(descriptor: passwordRuleDescriptor)
        textField.textContentType = .oneTimeCode
        textField.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        return textField
    }()

    lazy var usernameErrorLabel: ELDSLabel = {
        let label = ELDSLabel()
        label.insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .right
        return label
    }()

    lazy var passwordErrorLabel: ELDSLabel = {
        let label = ELDSLabel()
        label.insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .right
        return label
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    fileprivate func configureBaseUI() {
        view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        tableView.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

    @objc fileprivate func onTap() {
        view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        25
    }

}
