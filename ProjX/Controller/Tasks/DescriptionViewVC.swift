//
//  DescriptionViewVC.swift
//  ProjX
//
//  Created by Sathya on 20/04/23.
//

import UIKit

class DescriptionViewVC: PROJXViewController {

    lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .natural
        tv.textColor = .label
        tv.font = .systemFont(ofSize: 15)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.showsVerticalScrollIndicator = true
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
    }

    private func configureView() {
        title = "Task Description"
        view.addSubview(descriptionTextView)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
    }

    func setDescription(_ description: String) {
        descriptionTextView.text = description
    }

}
