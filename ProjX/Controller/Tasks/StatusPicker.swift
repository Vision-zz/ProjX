//
//  StatusPicker.swift
//  ProjX
//
//  Created by Sathya on 12/05/23.
//

import UIKit

class StatusPicker: PROJXViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let statusOptions = ["All", "In Progress", "Completed"]
    
    lazy var selectedStatus: TaskStatus = .inProgress
    weak var statusPickerDelegate: TaskStatusPickerDelegate?
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
    }
    
    private func configureView() {
        view.addSubview(pickerView)
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonClick))
        navigationController?.navigationBar.tintColor = GlobalConstants.Colors.accentColor
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
        ])
    }
    
    @objc private func closeButtonClick() {
        statusPickerDelegate?.selectedStatus(selectedStatus, dismiss: true)
    }
    
    func setSelectedStatus(_ status: TaskStatus) {
        selectedStatus = status
        let row = status == .unknown ? 0 : status == .inProgress ? 1 : 2
        pickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    // MARK: - UIPickerViewDataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusOptions.count
    }
    
    // MARK: - UIPickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let status = row == 0 ? TaskStatus.unknown : row == 1 ? TaskStatus.inProgress : TaskStatus.complete
        selectedStatus = status
        statusPickerDelegate?.selectedStatus(status, dismiss: false)
    }

}
