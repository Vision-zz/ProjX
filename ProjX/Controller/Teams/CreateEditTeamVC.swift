//
//  CreateTeamVC.swift
//  ProjX
//
//  Created by Sathya on 24/03/23.
//

import UIKit

class CreateEditTeamVC: PROJXViewController {

#if DEBUG
    deinit {
        print("Deinit CreateEditTeamVC")
    }
#endif

    private lazy var isCreatingTeam: Bool = true
    private lazy var editingTeam: Team? = nil
    private lazy var teamIconIsCustomized: Bool = false

    private lazy var teamName: String? = nil {
        didSet {
            teamNameTextField.text = teamName
        }
    }

    private lazy var teamIcon: UIImage? = nil {
        didSet {
            guard let teamIcon = teamIcon else {
                teamIconImageView.image = teamIconPlaceholderImage
                editingTeam?.removeTeamIcon()
                return
            }
            teamIconImageView.image = teamIcon
        }
    }
    private lazy var teamIconPlaceholderImage = UIImage(systemName: "photo.circle.fill")

    private lazy var teamIconImageView: UIImageView = {
        let imageView = UIImageView(image: teamIconPlaceholderImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }()

    private lazy var icon: UIButton = {
        let icon = UIButton()
        icon.addSubview(teamIconImageView)
        icon.menu = getMenu()
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        icon.showsMenuAsPrimaryAction = true
        return icon
    }()

    private lazy var charCountLabel: PROJXLabel = {
        let label = PROJXLabel()
        label.insets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        label.text = "\(64-(teamName?.count ?? 0))"
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    private lazy var teamNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Team Name"
        textField.autocorrectionType = .no
        textField.font = .systemFont(ofSize: 19, weight: .medium)
        var placeholder = NSMutableAttributedString(string: "Team Name", attributes: [
            .font: UIFont.systemFont(ofSize: 19, weight: .medium)
        ])
        textField.attributedPlaceholder = placeholder
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(nameTextFieldEdited), for: .editingChanged)
        textField.rightView = charCountLabel
        textField.rightViewMode = .always
        return textField

    }()

    private lazy var teamNameErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.text = " "
        label.textAlignment = .right
        return label
    }()

    private lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = .secondarySystemFill
        line.translatesAutoresizingMaskIntoConstraints = false
        line.isUserInteractionEnabled = false
        return line
    }()

    private lazy var teamInfoStack: UIStackView = {
        let teamTextFieldStack = UIStackView(arrangedSubviews: [teamNameTextField, line, teamNameErrorLabel])
        teamTextFieldStack.axis = .vertical
        teamTextFieldStack.distribution = .fillProportionally
        teamTextFieldStack.spacing = 3

        let stack = UIStackView(arrangedSubviews: [icon, teamTextFieldStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()


    private lazy var endButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitle("Create", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(createButtonOnClick), for: .touchUpInside)
        button.configuration = UIButton.Configuration.plain()
        return button
    }()

    weak var delegate: CreateEditTeamDelegate? = nil


    init(editingTeam: Team? = nil) {
        super.init(nibName: nil, bundle: nil)
        if editingTeam != nil {
            configureViewForEditing(team: editingTeam!)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
    }

    private func configureView() {
        title = isCreatingTeam ? "Create Team" : "Edit Team"
        view.addSubview(teamInfoStack)
        view.addSubview(endButton)
    }

    private func configureViewForEditing(team: Team) {
        self.isCreatingTeam = false
        self.editingTeam = team
        self.teamName = team.teamName ?? nil
        endButton.setTitle("Done", for: .normal)
        if team.hasTeamIcon() {
            teamIconIsCustomized = true
            self.teamIcon = team.getTeamIcon(reduceTo: CGSize(width: 40, height: 40))
        }
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamInfoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            teamInfoStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            teamInfoStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            teamInfoStack.heightAnchor.constraint(equalToConstant: 120),

            line.heightAnchor.constraint(equalToConstant: 1),

            icon.heightAnchor.constraint(equalToConstant: 100),
            icon.widthAnchor.constraint(equalToConstant: 100),
            teamIconImageView.heightAnchor.constraint(equalToConstant: 100),
            teamIconImageView.widthAnchor.constraint(equalToConstant: 100),

            endButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endButton.topAnchor.constraint(equalTo: teamInfoStack.bottomAnchor, constant: 20),
            endButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            endButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func getMenu() -> UIMenu {
        let menuElement = UIDeferredMenuElement.uncached { [weak self] completion in
            var children = [UIMenuElement]()
            if self?.teamIconIsCustomized != nil && self!.teamIconIsCustomized {
                children.append(UIAction(title: "Remove Image", image: UIImage(systemName: "trash")) { [weak self] _ in
                    self?.teamIconIsCustomized = false
                    self?.teamIcon = nil
                })
            }

            children.append(UIAction(title: "Choose Image", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
                guard let self = self else { return }
                PROJXImagePicker.shared.presentPicker(from: self) { image in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        self.teamIconIsCustomized = true
                        self.teamIcon = Util.downsampleImage(from: image.jpegData(compressionQuality: 0.75)!, to: CGSize(width: 40, height: 40))
                    }
                }
            })
            completion(children)
        }
        return UIMenu(children: [menuElement])
    }

    @objc private func nameTextFieldEdited() {
        teamName = teamNameTextField.text
        teamNameErrorLabel.text = " "
        let count = teamName?.count ?? 0
        charCountLabel.text = "\(64-count)"
        if count > 64 {
            charCountLabel.textColor = .systemRed
            line.backgroundColor = .systemRed
        } else {
            charCountLabel.textColor = .secondaryLabel
            line.backgroundColor = .secondarySystemFill
        }
    }

    @objc private func createButtonOnClick() {
        toggleButtonLoading()
        guard let teamName = teamName, !teamName.isEmpty else {
            teamNameErrorLabel.text = "Team name cannot be empty"
            toggleButtonLoading()
            return
        }
        guard teamName.count <= 64 else {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.duration = 0.3
            animation.values = [-3, 3, -2, 2, -1, 1, 0.0]
            charCountLabel.layer.add(animation, forKey: "shake")
            toggleButtonLoading()
            return
        }
        if isCreatingTeam {
            let newTeam = DataManager.shared.createTeam(name: teamName, image: teamIcon)
            delegate?.changesSaved(newTeam)
        } else {
            self.editingTeam?.teamName = teamName
            if teamIcon != nil {
                self.editingTeam?.setTeamIcon(image: teamIcon!)
            }
            delegate?.changesSaved(self.editingTeam!)
            DataManager.shared.saveContext()
        }
    }

    private func toggleButtonLoading() {
        endButton.configuration!.showsActivityIndicator.toggle()
        endButton.backgroundColor = endButton.configuration!.showsActivityIndicator ? .systemGray : .systemBlue
        endButton.setTitle(endButton.configuration!.showsActivityIndicator ? nil : isCreatingTeam ? "Create" : "Done", for: .normal)
    }

}

