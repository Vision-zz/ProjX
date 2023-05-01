//
//  PriorityPickerVC.swift
//  ProjX
//
//  Created by Sathya on 20/04/23.
//

import UIKit

class PriorityPickerVC: PROJXViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    let priorityOptions = ["High", "Medium", "Low"]

    lazy var selectedPriority: TaskPriority = .low
    weak var priorityPickerDelegate: PriorityPickerDelegate!
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
        view.backgroundColor = GlobalConstants.Colors.secondaryBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonClick))
        navigationController?.navigationBar.tintColor = GlobalConstants.Colors.accentColor
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func closeButtonClick() {
        priorityPickerDelegate.selectedPriority(selectedPriority, dismiss: true)
    }

    func setSelectedPriority(_ priority: TaskPriority) {
        selectedPriority = priority
        let row = priority == .high ? 0 : priority == .medium ? 1 : 2
        pickerView.selectRow(row, inComponent: 0, animated: true)
    }

        // MARK: - UIPickerViewDataSource methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorityOptions.count
    }

        // MARK: - UIPickerViewDelegate methods

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorityOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priority = row == 0 ? TaskPriority.high : row == 1 ? TaskPriority.medium : TaskPriority.low
        selectedPriority = priority
        priorityPickerDelegate.selectedPriority(priority, dismiss: false)
    }
}
