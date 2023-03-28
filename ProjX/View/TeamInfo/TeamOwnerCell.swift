//
//  TeamOwnerCell.swift
//  ProjX
//
//  Created by Sathya on 27/03/23.
//

import UIKit

class TeamOwnerCell: UITableViewCell {

    static let identifier = "TeamOwnerCell"

    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        icon.tintColor = .label
        return icon
    }()

    lazy var name: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .label
        name.textAlignment = .left
        name.lineBreakMode = .byTruncatingTail
        return name
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        var config = self.defaultContentConfiguration()
        config.text = "Owner"
        config.textProperties.font = .systemFont(ofSize: 14, weight: .semibold)
        config.textProperties.color = .secondaryLabel
        self.contentConfiguration = config
        self.contentView.addSubview(icon)
        self.contentView.addSubview(name)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.35),
            name.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            name.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            icon.widthAnchor.constraint(equalToConstant: 30),
            icon.heightAnchor.constraint(equalToConstant: 30),
            icon.trailingAnchor.constraint(equalTo: name.leadingAnchor, constant: -5),
            icon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
    }

    func configureCell(user: User) {
        icon.image = user.userProfileImage
        name.text = user.name ?? "-"

    }

}
