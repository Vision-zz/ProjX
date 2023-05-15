//
//  UserProfileNameCell.swift
//  ProjX
//
//  Created by Sathya on 14/05/23.
//

import UIKit

class UserProfileNameCell: UITableViewCell {
    
    static let identifier = "UserProfileNameCell"
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.type = .continuous
        label.numberOfLines = 1
        label.textAlignment = .center
        label.speed = .rate(40)
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    let teamName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
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
        contentView.addSubview(teamName)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            teamName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            teamName.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
        ])
    }
    
    func configure(with user: User, team: Team) {
        nameLabel.text = user.name
        profileImageView.image = user.getUserProfileIcon()
        teamName.text = "(\(team.teamName!))"
    }
}
