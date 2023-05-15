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
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11.5)
        return label
    }()
    
    private lazy var checkMark: UIImageView = {
        let checkMark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)))
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.tintColor = GlobalConstants.Colors.accentColor
        checkMark.isHidden = true
        checkMark.backgroundColor = .clear
        return checkMark
    }()
    
    override func prepareForReuse() {
        checkMark.isHidden = true
        checkMark.tintColor = GlobalConstants.Colors.accentColor
    }
    
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
        contentView.addSubview(statusLabel)
        contentView.addSubview(checkMark)

        NSLayoutConstraint.activate([
            checkMark.heightAnchor.constraint(equalToConstant: 17),
            checkMark.widthAnchor.constraint(equalToConstant: 17),
            checkMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            infoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            statusLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 2.5),
            statusLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7)
        ])
    }

    func configureCell(for taskItem: TaskItem, showsCompleted: Bool = false) {
        titleLabel.text = taskItem.title
        infoLabel.text = "Assigned To: \(taskItem.assignedToUser?.name ?? "Unknown")"
        statusLabel.text = "ETA: \(taskItem.deadline!.convertToString())"
        checkMark.isHidden = !(showsCompleted && taskItem.taskStatus == .complete)
    }

}
