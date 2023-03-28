//
//  TeamTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 22/03/23.
//

import UIKit

class TeamTableViewCell: UITableViewCell {

    lazy var teamIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    lazy var teamName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureCellUI()
        configureConstraints()
    }

    func configureCellData(teamIcon: UIImage? = nil, teamName: String) {
        self.teamName.text = teamName
        self.teamIcon.image = teamIcon
    }

    private func configureCellUI() {
        self.backgroundColor = GlobalConstants.Background.getColor(for: .secondary)
        self.accessoryType = .disclosureIndicator
        contentView.addSubview(teamIcon)
        contentView.addSubview(teamName)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamIcon.heightAnchor.constraint(equalToConstant: 35),
            teamIcon.widthAnchor.constraint(equalToConstant: 35),
            teamIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            teamIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),

            teamName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            teamName.leadingAnchor.constraint(equalTo: teamIcon.trailingAnchor, constant: 10),
        ])
    }

}
