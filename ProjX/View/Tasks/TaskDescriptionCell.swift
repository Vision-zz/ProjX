//
//  TaskDescriptionCell.swift
//  ProjX
//
//  Created by Sathya on 11/04/23.
//

import UIKit

class TaskDescriptionCell: UITableViewCell {

    static let identifier = "TaskDescriptionCell"

    lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .natural
        tv.textColor = .label
        tv.font = .systemFont(ofSize: 15)
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.showsVerticalScrollIndicator = true
        tv.isUserInteractionEnabled = false
        tv.isMultipleTouchEnabled = false
        return tv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionTextView.text = nil
    }

    private func configureCellView() {
        backgroundColor = GlobalConstants.Background.secondary
        contentView.addSubview(descriptionTextView)
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }

    func configureDescription(_ text: String) {
        descriptionTextView.text = text
    }
}
