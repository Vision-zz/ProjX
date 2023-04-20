//
//  AddTaskVC.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class AddTaskVC: PROJXTableViewController {

    lazy var assignedToUser: User? = SessionManager.shared.signedInUser
    lazy var priority: TaskPriority = .low
    weak var createTaskDelegate: CreateTaskDelegate?

    var priorityString: String {
        get {
            switch priority {
                case .low:
                    return "Low"
                case .medium:
                    return "Medium"
                default:
                    return "High"
            }
        }
    }

    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.clearButtonMode = .never
        textField.backgroundColor = .clear
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.allowsEditingTextAttributes = true
        textField.isUserInteractionEnabled = true
        return textField
    }()

    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = GlobalConstants.Background.secondary
        return textView
    }()

    lazy var deadlineDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.date = Date(timeIntervalSinceNow: 86400)
        picker.minimumDate = Date()
        return picker
    }()

    lazy var assignedToButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.imagePlacement = .trailing
        config.imagePadding = 5
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .right
        button.setTitle(assignedToUser?.name, for: .normal)
        if SessionManager.shared.signedInUser?.roleInCurrentTeam != .member {
            button.tintColor = .label
            button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            button.addTarget(self, action: #selector(assignedToButtonOnClick), for: .touchUpInside)
        } else {
            button.tintColor = .secondaryLabel
            button.isUserInteractionEnabled = false
        }
        return button
    }()

    lazy var priorityButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.imagePlacement = .trailing
        config.imagePadding = 5
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.label, for: .normal)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.setTitle(priorityString, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(priorityButtonClicked), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = "Add Task"
        tableView.register(AddTaskTableViewCell.self, forCellReuseIdentifier: AddTaskTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
    }

    @objc private func assignedToButtonOnClick() {
        let vc = TeamMemberSelector(team: SessionManager.shared.signedInUser!.selectedTeam!, selectedUser: assignedToUser)
        vc.selectionDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func priorityButtonClicked() {
        let vc = PriorityPickerVC()
        vc.priorityPickerDelegate = self
        vc.setSelectedPriority(priority)
        vc.modalPresentationStyle = .formSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in return 200 })]
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }

    @objc private func doneButtonOnClick() {

        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            let alert = UIAlertController(title: "Missing Title", message: "Title for the task is a required field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let descText = descriptionTextView.text, !descText.isEmpty else {
            let alert = UIAlertController(title: "Missing Description", message: "Description for the task is a required field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let createdTask = DataManager.shared.createTask(title: titleText, description: descText, deadLine: deadlineDatePicker.date, assignedTo: assignedToUser!, priority: priority)
        createTaskDelegate?.taskCreated(createdTask)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddTaskTableViewCell.identifier, for: indexPath) as! AddTaskTableViewCell

        switch indexPath.row {
            case 0:
                cell.configureCellView(key: "Title") { [unowned self] cellView in
                    cellView.addSubview(self.titleTextField)
                    NSLayoutConstraint.activate([
                        self.titleTextField.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.titleTextField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 5),
                        self.titleTextField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.titleTextField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor),
                    ])
                }
            case 1:
                cell.configureCellView(key: "Task Description") { [unowned self] cellView in
                    cellView.addSubview(self.descriptionTextView)
                    NSLayoutConstraint.activate([
                        self.descriptionTextView.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.descriptionTextView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor),
                        self.descriptionTextView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.descriptionTextView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor),
                    ])
                }
            case 2:
                cell.configureCellView(key: "Deadline") { [unowned self] cellView in
                    cellView.addSubview(self.deadlineDatePicker)
                    NSLayoutConstraint.activate([
                        self.deadlineDatePicker.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
                        self.deadlineDatePicker.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15)

                    ])
                }
            case 3:
                cell.configureCellView(key: "Assign To") { [unowned self] cellView in
                    cellView.addSubview(self.assignedToButton)
                    NSLayoutConstraint.activate([
                        self.assignedToButton.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
                        self.assignedToButton.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
                        self.assignedToButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15),
                    ])
                }
            case 4:
                cell.configureCellView(key: "Priority") { [unowned self] cellView in
                    cellView.addSubview(priorityButton)
                    NSLayoutConstraint.activate([
                        self.priorityButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                        self.priorityButton.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
                        self.priorityButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15),
                    ])
                }
            default:
                fatalError()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 160
        }
        return 44
    }
}

extension AddTaskVC: AssignedToSelectionDelegate {
    func taskAssigned(to user: User) {
        assignedToUser = user
        assignedToButton.setTitle(user.name, for: .normal)
        navigationController?.popViewController(animated: true)
    }
}

extension AddTaskVC: PriorityPickerDelegate {
    func selectedPriority(_ priority: TaskPriority) {
        self.priority = priority
        priorityButton.setTitle(priorityString, for: .normal)
        dismiss(animated: true)
    }
}
