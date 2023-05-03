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

    lazy var completedIndicator: UIView = {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor(named: "Clover Green")
        indicator.isUserInteractionEnabled = false
        indicator.layer.cornerRadius = 4
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
        contentView.clipsToBounds = true
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(completedIndicator)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            infoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            completedIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            completedIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completedIndicator.heightAnchor.constraint(equalToConstant: 8),
            completedIndicator.widthAnchor.constraint(equalToConstant: 8),
        ])
    }

    func configureCell(for taskItem: TaskItem, showsCompleted: Bool = false) {
        titleLabel.text = taskItem.title
        infoLabel.text = taskItem.taskDescription
        completedIndicator.isHidden = !(showsCompleted && taskItem.taskStatus == .complete)
    }

}
