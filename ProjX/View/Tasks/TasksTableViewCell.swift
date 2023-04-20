//
//  TasksTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    static let identifier = "TasksTableViewCell"

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11)
        return label
    }()

    lazy var completedIndicator: UIView = {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor(hex: 0x20920f)
        indicator.isUserInteractionEnabled = false
        indicator.layer.cornerRadius = 10
        indicator.isHidden = true
        return indicator
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(createdAtLabel)
        contentView.addSubview(completedIndicator)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: createdAtLabel.leadingAnchor, constant: -2),

            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            infoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            createdAtLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            createdAtLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            createdAtLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.55),

            completedIndicator.centerXAnchor.constraint(equalTo: contentView.leadingAnchor),
            completedIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completedIndicator.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85),
            completedIndicator.widthAnchor.constraint(equalToConstant: 6)
        ])
    }

    func configureCell(for taskItem: TaskItem, showsCompleted: Bool = false) {
        titleLabel.text = taskItem.title
        infoLabel.text = "created by \(taskItem.createdByUser.name!)"
        createdAtLabel.text = taskItem.createdAt?.convertToString()
        completedIndicator.isHidden = !(showsCompleted && taskItem.taskStatus == .complete)
    }

}
