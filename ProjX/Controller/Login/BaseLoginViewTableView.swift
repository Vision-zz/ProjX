//
//  BaseLoginViewTableViewTableViewController.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import UIKit

class BaseLoginViewTableView: PROJXTableViewController {

    lazy var usernameTextField = createTextField(placeholder: "Username*")

    lazy var passwordTextField: UITextField = {
        var textField = createTextField(placeholder: "Password*")
        textField.enablePasswordToggle()
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()

    lazy var usernameErrorLabel: PROJXLabel = createErrorLabel()

    lazy var passwordErrorLabel: PROJXLabel = createErrorLabel()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "Default Blurple")
        button.layer.cornerRadius = 7
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = GlobalConstants.Colors.primaryBackground
        tableView.backgroundColor = GlobalConstants.Colors.primaryBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        cancelButton.tintColor = UIColor(named: "Default Blurple")
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc func cancelButtonPressed() {
        self.dismiss(animated: true)
    }

    func createErrorLabel() -> PROJXLabel {
        let label = PROJXLabel()
        label.insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .right
        return label
    }

    func resetErrorLabel(_ label: UILabel) {
        guard let text = label.text, !text.isEmpty else {
            return
        }
        label.text = ""
    }

    func createTextField(placeholder: String, with keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = GlobalConstants.Colors.secondaryBackground
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.keyboardType = keyboardType
        return textField
    }

    func configureCellForLoginButton(_ cell: UITableViewCell, title: String, selector: Selector) {
        loginButton.addTarget(self, action: selector, for: .touchUpInside)
        loginButton.setTitle(title, for: .normal)
        cell.contentView.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 30),
            loginButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
    }

    func configureCellForLoginTypeSwitch(_ cell: UITableViewCell, buttonSelector: Selector, labelText: String, buttonTitle: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelText
        label.textColor = .label
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.tintColor = UIColor(named: "Default Blurple")
        button.addTarget(self, action: buttonSelector, for: .touchUpInside)

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
