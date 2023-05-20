//
//  TasksTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    static let identifier = "TasksTableViewCell"
    
    lazy var taskItem: TaskItem? = nil
    weak var delegate: MarkAsCompleteActionDelegate? = nil

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
    
    var checkMarkImage: UIImage {
        get {
            guard let taskItem = taskItem else {
                return UIImage(systemName: "questionmark.square")!
            }
            if taskItem.taskStatus != .complete {
                return UIImage(systemName: "square")!
            } else {
                return UIImage(systemName: "checkmark.square")!
            }
        }
    }
    
    var checkMarkTintColor: UIColor {
        get {
            if let taskItem = taskItem, let assignedTo = taskItem.assignedTo, assignedTo == SessionManager.shared.signedInUser?.userID {
                return GlobalConstants.Colors.accentColor
            } else {
                return GlobalConstants.Colors.accentColor.dim
            }
        }
    }

    lazy var checkMark: UIButton = {
        let check = UIButton()
        check.isUserInteractionEnabled = true
        check.translatesAutoresizingMaskIntoConstraints = false
        check.tintColor = checkMarkTintColor
        check.backgroundColor = .clear
        check.addTarget(self, action: #selector(checkMarkclicked), for: .touchUpInside)
        check.configuration = buttonConfig
        return check
    }()

    var buttonConfig: UIButton.Configuration {
        get {
            var config = UIButton.Configuration.plain()
            config.image = checkMarkImage
            config.buttonSize = .medium
            return config
        }
    }
    
    override func prepareForReuse() {
        taskItem = nil
        checkMark.tintColor = checkMarkTintColor
        checkMark.configuration = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellView() {
        separatorInset = UIEdgeInsets(top: 0, left: 43, bottom: 0, right: 0)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(checkMark)

        NSLayoutConstraint.activate([
            checkMark.heightAnchor.constraint(equalToConstant: 25),
            checkMark.widthAnchor.constraint(equalToConstant: 25),
            checkMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: checkMark.trailingAnchor, constant: 8),
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
        self.taskItem = taskItem
        titleLabel.text = taskItem.title
        
        let infoString = NSMutableAttributedString(string: "Assigned To: ", attributes: [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.secondaryLabel,
        ])
        
        if let assignedTo = taskItem.assignedTo, SessionManager.shared.signedInUser?.userID == assignedTo {
            infoString.append(NSMutableAttributedString(string: "You", attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.label
            ]))
        } else {
            infoString.append(NSMutableAttributedString(string: "\(taskItem.assignedToUser?.name ?? "Unknown")", attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.secondaryLabel
            ]))
        }
        
        infoLabel.attributedText = infoString
        statusLabel.text = "ETA: \(taskItem.deadline!.convertToString())"
        checkMark.configuration = buttonConfig
        checkMark.tintColor = checkMarkTintColor
    }
    
    @objc private func checkMarkclicked() {
        guard let taskItem = taskItem, taskItem.taskStatus != .complete else { return }
        delegate?.markAsCompletedActionTriggered(for: taskItem)
    }
    
}
