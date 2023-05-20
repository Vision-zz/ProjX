//
//  ProfileCell.swift
//  ProjX
//
//  Created by Sathya on 20/04/23.
//

import UIKit

class ProfileCell: UITableViewCell {

    static let identifier = "ProfileCell"

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCellView() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            emailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 12),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.emailID
        profileImageView.image = user.getUserProfileIcon()
    }

}
