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
    weak var createTaskDelegate: CreateTaskDelegate?

    lazy var priority: TaskPriority = .low
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
        textField.delegate = self
        textField.tintColor = GlobalConstants.Colors.accentColor
        return textField
    }()
    
    private lazy var titleCharCountLabel: PROJXLabel = {
        let label = PROJXLabel()
        label.insets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        label.text = "\(64-(titleTextField.text?.count ?? 0))"
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.tintColor = GlobalConstants.Colors.accentColor
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    private lazy var descCharCountLabel: PROJXLabel = {
        let label = PROJXLabel()
        label.insets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        label.text = "\(64-(titleTextField.text?.count ?? 0))"
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
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
        tableView.register(FormsTableViewCell.self, forCellReuseIdentifier: FormsTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
        titleTextField.becomeFirstResponder()
    }
    
    @objc private func doneButtonOnClick() {

        guard let title = titleTextField.text,  !title.isEmpty else {
            let alert = UIAlertController(title: "Mandatory Field", message: "Title is a mandatory field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        guard let titleText = Util.cleanInputString(from: title), !titleText.isEmpty else {
            let alert = UIAlertController(title: "Invalid Title", message: "Enter a valid non-empty title for the task", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

        guard let desc = descriptionTextView.text, !desc.isEmpty else {
            let alert = UIAlertController(title: "Mandatory Field", message: "Description is a mandatory field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        guard let descText = Util.cleanInputString(from: desc), !descText.isEmpty else {
            let alert = UIAlertController(title: "Invalid Description", message: "Enter a valid non-empty description for the task", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: FormsTableViewCell.identifier, for: indexPath) as! FormsTableViewCell

        switch indexPath.row {
            case 0:
                cell.configureCellView(key: "Title") { [unowned self] cellView in
                    cellView.addSubview(self.titleTextField)
                    NSLayoutConstraint.activate([
                        self.titleTextField.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.titleTextField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 5),
                        self.titleTextField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.titleTextField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -5),
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
                let vc = SelectUserVC(team: SessionManager.shared.signedInUser!.selectedTeam!, selectedUser: assignedToUser)
                vc.selectionDelegate = self
                navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = PriorityPickerVC()
                vc.priorityPickerDelegate = self
                vc.setSelectedPriority(priority)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .formSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.custom(resolver: { _ in return 200 })]
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

extension AddOrEditTaskVC: MemberSelectionDelegate {
    func selected(user: User) {
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

extension AddOrEditTaskVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
    }
}
