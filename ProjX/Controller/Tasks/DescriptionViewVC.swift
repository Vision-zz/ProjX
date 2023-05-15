//
//  DescriptionViewVC.swift
//  ProjX
//
//  Created by Sathya on 20/04/23.
//

import UIKit

class DescriptionViewVC: PROJXViewController {

    deinit {
        print("Deinit DescriptionView")
    }

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descriptionTextView.contentOffset.y = 0
    }

    private func configureView() {
        title = "Task Description"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = GlobalConstants.Colors.secondaryBackground
        view.addSubview(descriptionTextView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonClick))
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

    @objc private func closeButtonClick() {
        self.dismiss(animated: true)
    }


}
