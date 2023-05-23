//
//  ReassignTeamTaskCell.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import UIKit

class ReassignTeamTaskCell: UITableViewCell {

    static let identifier = "ReassignTeamTaskCell"
    
    var taskItem: TaskItem! = nil
    weak var delegate: ReassignForTaskDelegate? = nil
    
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
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 1
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
    
    lazy var assignToButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.title = "Assign To"
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = GlobalConstants.Colors.accentColor
        button.tintColor = .white
        button.addTarget(self, action: #selector(assignToButtonOnClick), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 6
        return button
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
        contentView.addSubview(statusLabel)
        contentView.addSubview(assignToButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            infoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            statusLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 2.5),
            statusLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            
            assignToButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            assignToButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    func configureCell(for taskItem: TaskItem) {
        self.taskItem = taskItem
        titleLabel.text = taskItem.title
        infoLabel.text = "Created By: \(taskItem.createdByUser.name ?? "Unknown")"
        statusLabel.text = "ETA: \(taskItem.deadline!.convertToString())"
    }
    
    @objc private func assignToButtonOnClick() {
        delegate?.reassinged(for: taskItem)
    }
    
}
