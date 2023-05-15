//
//  ProfileMenuVC.swift
//  ProjX
//
//  Created by Sathya on 27/04/23.
//

import UIKit

class NameEmailVC: PROJXTableViewController {

    lazy var user: User! = nil
    weak var profileUpdateDelegate: ProfileUpdateDelegate? = nil
    lazy var profilePlaceholderImage = Util.generateInitialImage(from: user.name!)
    private lazy var profileIconIsCustomized: Bool = false

    private lazy var someValueChanged = false {
        didSet {
            if someValueChanged == true {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked))
            }
        }
    }

    private lazy var profileIcon: UIImage? = user.hasUserProfileIcon() ? user.getUserProfileIcon() : nil {
        didSet {
            guard let profileIcon = profileIcon else {
                profileImageView.image = profilePlaceholderImage
                profileIconIsCustomized = false
                return
            }
            profileIconIsCustomized = true
            profileImageView.image = profileIcon
        }
    }

    private lazy var name = user.name
    private lazy var email = user.emailID

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(image: user.hasUserProfileIcon() ? user.getUserProfileIcon() : profilePlaceholderImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()

    private lazy var nameTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = name
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .default
        tv.addTarget(self, action: #selector(nameTextEdited), for: .editingChanged)
        tv.autocorrectionType = .no
        return tv
    }()

    private lazy var emailTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = email
        tv.tintColor = GlobalConstants.Colors.accentColor
        tv.keyboardType = .emailAddress
        tv.addTarget(self, action: #selector(emailTextEdited), for: .editingChanged)
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        return tv
    }()

    private lazy var icon: UIButton = {
        let icon = UIButton()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.addSubview(profileImageView)
        icon.isUserInteractionEnabled = true
        icon.menu = getMenu()
        icon.showsMenuAsPrimaryAction = true
        return icon
    }()

    convenience init(user: User) {
        self.init(style: .insetGrouped)
        self.user = user
        self.profileIconIsCustomized = user.hasUserProfileIcon()
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
        title = "Name, Profile Image, Email"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NameEmailCell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonClicked))
    }

    @objc private func nameTextEdited() {
        someValueChanged = true
        guard let udpatedName = nameTextField.text, !udpatedName.isEmpty else {
            name = ""
            return
        }
        name = nameTextField.text
    }

    @objc private func emailTextEdited() {
        someValueChanged = true
        guard let udpatedEmail = emailTextField.text, !udpatedEmail.isEmpty else {
            name = ""
            return
        }
        email = emailTextField.text
    }

    @objc private func cancelButtonClicked() {
        dismiss(animated: true)
    }

    @objc private func doneButtonClicked() {
        guard let udpatedName = nameTextField.text, !udpatedName.isEmpty else {
            showErrorAlert(title: "Empty Field", message: "Name cannot be empty")
            return
        }
        guard let udpatedEmail = emailTextField.text, !udpatedEmail.isEmpty else {
            showErrorAlert(title: "Empty Field", message: "Email address cannot be empty")
            return
        }
        guard InputValidator.validate(email: email!) else {
            showErrorAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        saveChanges()
    }

    private func saveChanges() {
        user.name = name
        user.emailID = email
        if let profileIcon = profileIcon, profileIconIsCustomized {
            user.setUserProfileIcon(image: profileIcon)
        } else {
            user.deleteUserProfileIcon()
        }
        DataManager.shared.saveContext()
        profileUpdateDelegate?.profileUpdated()
        self.dismiss(animated: true)
    }


    private func getMenu() -> UIMenu {
        let menuElement = UIDeferredMenuElement.uncached { [weak self] completion in
            var children = [UIMenuElement]()
            if self?.profileIconIsCustomized != nil && self!.profileIconIsCustomized {
                children.append(UIAction(title: "Remove Image", image: UIImage(systemName: "trash")) { [weak self] _ in
                    self?.profileIconIsCustomized = false
                    self?.profileIcon = nil
                    self?.someValueChanged = true
                })
            }

            children.append(UIAction(title: "Choose Image", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
                guard let self = self else { return }
                PROJXImagePicker.shared.presentPicker(from: self) { image in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        self.profileIconIsCustomized = true
                        self.profileIcon = image
                        self.someValueChanged = true
                    }
                }
            })
            DispatchQueue.main.async {
                completion(children)
            }
        }
        return UIMenu(children: [menuElement])
    }

    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Name"
        } else if section == 2 {
            return "Email"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "This name will be displayed to other users using ProjX"
        }
        return nil
    }

    private func configureProfileCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(icon)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 100),
            icon.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            icon.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        return cell
    }

    private func configureNameCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            nameTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
        ])
        return cell
    }

    private func configureEmailCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            emailTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
        ])
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureProfileCell()
        } else if indexPath.section == 1 {
            return configureNameCell()
        } else {
            return configureEmailCell()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 44
    }

}
