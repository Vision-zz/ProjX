//
//  ChangePasswordVC.swift
//  ProjX
//
//  Created by Sathya on 28/04/23.
//

import UIKit

class ChangePasswordVC: PROJXTableViewController {

    weak var passwordChangeDelegate: PasswordUpdateDelegate? = nil
    
    lazy var oldTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.placeholder = "old password"
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .default
        tv.addTarget(self, action: #selector(oldTextEdited), for: .editingChanged)
        tv.autocorrectionType = .no
        tv.isSecureTextEntry = true
        tv.textContentType = .oneTimeCode
        tv.returnKeyType = .next
        tv.delegate = self
        return tv
    }()
    
    lazy var newTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.placeholder = "enter password"
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .default
        tv.addTarget(self, action: #selector(newTextEdited), for: .editingChanged)
        tv.autocorrectionType = .no
        tv.isSecureTextEntry = true
        tv.textContentType = .oneTimeCode
        tv.returnKeyType = .next
        tv.delegate = self
        return tv
    }()

    lazy var verifyTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.placeholder = "re-enter password"
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .default
        tv.addTarget(self, action: #selector(verifyTextEdited), for: .editingChanged)
        tv.autocorrectionType = .no
        tv.isSecureTextEntry = true
        tv.textContentType = .oneTimeCode
        tv.returnKeyType = .done
        tv.delegate = self
        return tv
    }()

    lazy var userOldPassword: String = ""
    lazy var oldPassword: String = ""
    lazy var newPassword: String = ""
    lazy var verifyPassword: String = ""

    convenience init(oldPassword: String) {
        self.init(style: .insetGrouped)
        self.userOldPassword = oldPassword
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
        title = "Change Password"
        navigationItem.largeTitleDisplayMode = .never
        oldTextField.becomeFirstResponder()
        tableView.keyboardDismissMode = .onDrag
    }

    private func createKeyLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.text = text
        return label
    }

    private func setDoneButton(_ state: Bool) {
        if state {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func showErrorAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: handler))
        present(alert, animated: true)
    }

    @objc private func doneButtonOnClick() {
        
        guard let _ = oldTextField.text, let _ = newTextField.text, let _ = verifyTextField.text else {
            showErrorAlert(title: "Error", message: "Passwords field cannot be empty")
            return
        }
        if oldPassword != userOldPassword {
            showErrorAlert(title: "Error", message: "Old password is wrong", handler: { _ in
                self.oldTextField.becomeFirstResponder()
                self.oldTextField.selectAll(nil)
            })
        }
        if newPassword != verifyPassword {
            showErrorAlert(title: "Error", message: "Passwords do not match", handler: { _ in
                self.verifyTextField.becomeFirstResponder()
                self.verifyTextField.selectAll(nil)
            })
            return
        }
        passwordChangeDelegate?.passwordChanged(to: newPassword)
    }

    @objc private func newTextEdited() {
        guard let newPass = newTextField.text else {
            newPassword = ""
            return 
        }
        newPassword = newPass
        setDoneButton(!newPassword.isEmpty && !verifyPassword.isEmpty && !oldPassword.isEmpty)
    }

    @objc private func verifyTextEdited() {
        guard let verifyPass = verifyTextField.text else {
            verifyPassword = ""
            return
        }
        verifyPassword = verifyPass
        setDoneButton(!newPassword.isEmpty && !verifyPassword.isEmpty && !oldPassword.isEmpty)
    }
    
    @objc private func oldTextEdited() {
        guard let oldPass = oldTextField.text else {
            oldPassword = ""
            return
        }
        oldPassword = oldPass
        setDoneButton(!newPassword.isEmpty && !verifyPassword.isEmpty && !oldPassword.isEmpty)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }

    private func configureCell(with name: String, textField: UITextField) -> UITableViewCell {
        let cell = UITableViewCell()
        let label = createKeyLabel(with: name)
        cell.contentView.addSubview(label)
        cell.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            label.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 0.3),
            label.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),

            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        ])
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureCell(with: "Old", textField: oldTextField)
        }
        if indexPath.row == 0 {
            return configureCell(with: "New", textField: newTextField)
        } else if indexPath.row == 1 {
            return configureCell(with: "Verify", textField: verifyTextField)
        }
        fatalError()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

}

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case newTextField:
                verifyTextField.becomeFirstResponder()
            default:
                doneButtonOnClick()
                textField.resignFirstResponder()
        }
        return true
    }
}
