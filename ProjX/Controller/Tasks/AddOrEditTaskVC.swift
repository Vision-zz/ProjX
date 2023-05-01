//
//  AddTaskVC.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class AddOrEditTaskVC: PROJXTableViewController {

    lazy var isEditingTask: Bool = false
    lazy var editingTask: TaskItem? = nil
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
        textField.tintColor = GlobalConstants.Colors.accentColor
        return textField
    }()

    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.tintColor = GlobalConstants.Colors.accentColor
        textView.font = .systemFont(ofSize: 16)
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

    var assignedToIsChangeable: Bool { return SessionManager.shared.signedInUser!.roleInCurrentTeam != .member }
    lazy var assignedToLabel: UILabel = {
        let label = UILabel()
        label.text = assignedToUser?.name
        label.backgroundColor = .clear
        if SessionManager.shared.signedInUser?.roleInCurrentTeam != .member {
            label.textColor = .label
        } else {
            label.textColor = .secondaryLabel
        }
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var priorityLabel: UILabel = {
        let label = UILabel()
        label.text = priorityString
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = isEditingTask ? "Edit task" : "Add Task"
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = GlobalConstants.Colors.primaryBackground
        tableView.register(AddTaskTableViewCell.self, forCellReuseIdentifier: AddTaskTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
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

        if let editingTask = editingTask, isEditingTask {
            editingTask.title = titleText
            editingTask.taskDescription = descText
            editingTask.deadline = deadlineDatePicker.date
            editingTask.assignedToUser = assignedToUser
            editingTask.taskPriority = priority
            DataManager.shared.saveContext()
            createTaskDelegate?.taskCreatedOrUpdated(editingTask)
        } else {
            let createdTask = DataManager.shared.createTask(title: titleText, description: descText, deadLine: deadlineDatePicker.date, assignedTo: assignedToUser!, priority: priority)
            createTaskDelegate?.taskCreatedOrUpdated(createdTask)
        }
    }

    func configureViewForEditing(task: TaskItem) {
        self.isEditingTask = true
        self.editingTask = task
        self.titleTextField.text = task.title
        self.descriptionTextView.text = task.taskDescription
        self.assignedToUser = task.assignedToUser
        self.priority = task.taskPriority
        if task.deadline != nil {
            self.deadlineDatePicker.date = task.deadline!
        }
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
                        self.deadlineDatePicker.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10)

                    ])
                }
            case 3:
                cell.accessoryType = assignedToIsChangeable ? .disclosureIndicator : .none
                cell.configureCellView(key: "Assign To") { [unowned self] cellView in
                    cellView.addSubview(self.assignedToLabel)
                    NSLayoutConstraint.activate([
                        self.assignedToLabel.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.assignedToLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
                        self.assignedToLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.assignedToLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15),
                    ])
                }
            case 4:
                cell.accessoryType = .disclosureIndicator
                cell.configureCellView(key: "Priority") { [unowned self] cellView in
                    cellView.addSubview(priorityLabel)
                    NSLayoutConstraint.activate([
                        self.priorityLabel.topAnchor.constraint(equalTo: cell.topAnchor),
                        self.priorityLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
                        self.priorityLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.priorityLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -15),
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 3:
                let vc = TeamMemberSelector(team: SessionManager.shared.signedInUser!.selectedTeam!, selectedUser: assignedToUser)
                vc.selectionDelegate = self
                navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = PriorityPickerVC()
                vc.priorityPickerDelegate = self
                vc.setSelectedPriority(priority)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .formSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.custom(resolver: { _ in return 250 })]
                    sheet.preferredCornerRadius = 20
                }
                present(nav, animated: true)
            default:
                return
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.row {
            case 3:
                if SessionManager.shared.signedInUser?.roleInCurrentTeam != .member {
                    return indexPath
                }
            case 4:
                return indexPath
            default:
                return nil
        }
        return nil
    }
}

extension AddOrEditTaskVC: AssignedToSelectionDelegate {
    func taskAssigned(to user: User) {
        assignedToUser = user
        assignedToLabel.text = user.name
        navigationController?.popViewController(animated: true)
    }
}

extension AddOrEditTaskVC: PriorityPickerDelegate {
    func selectedPriority(_ priority: TaskPriority, dismiss: Bool) {
        self.priority = priority
        priorityLabel.text = priorityString
        if dismiss {
            self.dismiss(animated: true)
        }
    }
}
