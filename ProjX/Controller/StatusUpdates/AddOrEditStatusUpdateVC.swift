//
//  AddStatusUpdateVC.swift
//  ProjX
//
//  Created by Sathya on 16/05/23.
//

import UIKit

class AddOrEditStatusUpdateVC: PROJXTableViewController {
    
    lazy var isEditingUpdate: Bool = false
    lazy var editingUpdate: TaskStatusUpdate? = nil
    weak var delegate: StatusUpdateDelegate? = nil
    
    lazy var subjectTextField: UITextField = {
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
        textField.delegate = self
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

    override func viewDidLoad() {
        super.viewDidLoad()

       configureView()
    }
    
    private func configureView() {
        title = isEditingUpdate ? "Edit Status Update" : "Add Status Update"
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = GlobalConstants.Colors.primaryBackground
        tableView.register(FormsTableViewCell.self, forCellReuseIdentifier: FormsTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonOnClick))
        subjectTextField.becomeFirstResponder()
    }
    
    func configureViewForEditing(statusUpdate: TaskStatusUpdate) {
        self.isEditingUpdate = true
        self.editingUpdate = statusUpdate
        self.subjectTextField.text = statusUpdate.subject
        self.descriptionTextView.text = statusUpdate.statusDescription
    }

    @objc private func doneButtonOnClick() {
        
        guard let titleText = Util.cleanInputString(from: subjectTextField.text),  !titleText.isEmpty else {
            let alert = UIAlertController(title: "Invalid Subject", message: "Enter a valid Subject for the update", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        guard let descText = Util.cleanInputString(from: descriptionTextView.text), !descText.isEmpty else {
            let alert = UIAlertController(title: "Invalid Description", message: "Enter a valid description for the update", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        if let editingTask = editingUpdate, isEditingUpdate {
            editingTask.subject = titleText
            editingTask.statusDescription = descText
            delegate?.statusUpdateEdited(editingTask)
        } else {
            let statusUpdate = TaskStatusUpdate(context: DataManager.shared.context)
            statusUpdate.subject = titleText
            statusUpdate.statusDescription = descText
            statusUpdate.createdAt = Date()
            delegate?.statusUpdateCreated(statusUpdate)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormsTableViewCell.identifier, for: indexPath) as! FormsTableViewCell
        
        switch indexPath.row {
            case 0:
                cell.configureCellView(key: "Subject") { [unowned self] cellView in
                    cellView.addSubview(self.subjectTextField)
                    NSLayoutConstraint.activate([
                        self.subjectTextField.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.subjectTextField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 5),
                        self.subjectTextField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.subjectTextField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -5),
                    ])
                }
            case 1:
                cell.configureCellView(key: "Description") { [unowned self] cellView in
                    cellView.addSubview(self.descriptionTextView)
                    NSLayoutConstraint.activate([
                        self.descriptionTextView.topAnchor.constraint(equalTo: cellView.topAnchor),
                        self.descriptionTextView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor),
                        self.descriptionTextView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
                        self.descriptionTextView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor),
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

extension AddOrEditStatusUpdateVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
    }
}
