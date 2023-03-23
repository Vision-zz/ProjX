//
//  HomeCollectionViewCell.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import UIKit

class HomeCollectionViewTaskCell: UICollectionViewCell {
    static let identifier = "HomeCollectionViewTaskCell"

    lazy var data: TaskItem? = nil {
        didSet {
            guard let data = data else { return }
            titleLabel.text = data.title
            descriptionLabel.text = data.taskDescription != nil ? "  " + data.taskDescription! : nil
            scheduleLabel.text = data.deadline != nil ? "Scheduled on " + data.deadline!.convertToString() : "Not Scheduled"
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 23 : 20, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 17 : 14)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 11 : 8)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellUI()
        configureSubViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(rect: self.bounds.inset(by: UIEdgeInsets(top: 15, left: 15, bottom: 3, right: 3))).cgPath
    }

    private func configureCellUI() {
        self.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.clear.cgColor

        self.layer.shadowColor = GlobalConstants.Background.getColor(for: .shadow).cgColor
        self.layer.shadowRadius = 7.5
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    func configureSubViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(scheduleLabel)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.2),
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -3),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            descriptionLabel.bottomAnchor.constraint(equalTo: scheduleLabel.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 7),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -3),

            scheduleLabel.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.15),
            scheduleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            scheduleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),

        ])
    }

}
