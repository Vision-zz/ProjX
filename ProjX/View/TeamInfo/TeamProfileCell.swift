//
//  TeamProfileCell.swift
//  ProjX
//
//  Created by Sathya on 27/03/23.
//

import UIKit

class TeamProfileCell: UITableViewCell {
    deinit {
        print("Deinit TeamProfileCell")
    }

    static let identifier = "TeamProfileCell"

    lazy var team: Team! = nil
    weak var teamOptionsDelegate: TeamOptionsDelegate? = nil

    lazy var teamIcon: UIImageView = {
        let teamIcon = UIImageView()
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        teamIcon.clipsToBounds = true
        teamIcon.contentMode = .scaleAspectFill
        teamIcon.tintColor = .label
        teamIcon.layer.cornerRadius = 40
        return teamIcon
    }()

    lazy var teamNameLabel: UILabel = {
        let teamNameLabel = UILabel()
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.textAlignment = .left
        teamNameLabel.numberOfLines = 1
        teamNameLabel.lineBreakMode = .byTruncatingTail
        teamNameLabel.textColor = .label
        teamNameLabel.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 28 : 24, weight: .bold)
        return teamNameLabel
    }()
    
    lazy var teamInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()

    lazy var teamOptionsButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .medium
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = GlobalConstants.Colors.accentColor
        button.showsMenuAsPrimaryAction = true
        return button
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
        self.contentView.addSubview(teamIcon)
        self.contentView.addSubview(teamNameLabel)
        self.contentView.addSubview(teamInfoLabel)
        self.contentView.addSubview(teamOptionsButton)
   }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            teamIcon.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.8),
            teamIcon.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.8),
            teamIcon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            teamNameLabel.leadingAnchor.constraint(equalTo: teamIcon.trailingAnchor, constant: 15),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamOptionsButton.leadingAnchor, constant: -10),
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIcon.centerYAnchor),

            teamInfoLabel.leadingAnchor.constraint(equalTo: teamNameLabel.leadingAnchor),
            teamInfoLabel.trailingAnchor.constraint(equalTo: teamNameLabel.trailingAnchor),
            teamInfoLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor),
            
            teamOptionsButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            teamOptionsButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            teamOptionsButton.widthAnchor.constraint(equalToConstant: 25),
        ])
    }

    private func configureButtonMenu(for team: Team) {
        teamOptionsButton.menu = MenuProvider.getTeamProfileOptionsMenu(for: team, delegate: teamOptionsDelegate)
    }

    func configureCell(team: Team) {
        self.team = team
        teamIcon.image = team.getTeamIcon(reduceTo: CGSize(width: 60, height: 60))

        let teamCreatedAt = NSMutableAttributedString(string: "\(team.teamMembers.count + team.teamAdmins.count + 1) Members\nCreated on \(team.teamCreatedAt!.convertToString())", attributes: [
            .font: UIFont.systemFont(ofSize: GlobalConstants.Device.isIpad ? 17 : 12),
            .foregroundColor: UIColor.secondaryLabel,
        ])
        teamNameLabel.text = team.teamName ?? "---"
        teamInfoLabel.attributedText = teamCreatedAt
        
        if team.isSelected {
            teamIcon.layer.borderWidth = 2
            teamIcon.layer.borderColor = UIColor.systemGreen.cgColor
        }
        configureButtonMenu(for: team)
    }

}
