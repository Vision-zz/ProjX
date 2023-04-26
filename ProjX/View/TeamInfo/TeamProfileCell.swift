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
        teamIcon.layer.cornerRadius = 30
        return teamIcon
    }()

    lazy var teamNameLabel: UILabel = {
        let teamNameLabel = UILabel()
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.textAlignment = .left
        teamNameLabel.numberOfLines = 3
        teamNameLabel.lineBreakMode = .byTruncatingTail
        teamNameLabel.textColor = .label
        return teamNameLabel
    }()

    lazy var teamOptionsButton: UIButton = {
        let button = UIButton()
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

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        self.contentView.addSubview(teamIcon)
        self.contentView.addSubview(teamNameLabel)
        self.contentView.addSubview(teamOptionsButton)
   }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            teamIcon.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.6),
            teamIcon.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.6),
            teamIcon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            teamNameLabel.leadingAnchor.constraint(equalTo: teamIcon.trailingAnchor, constant: 15),
            teamNameLabel.centerYAnchor.constraint(equalTo: teamIcon.centerYAnchor),

            teamOptionsButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            teamOptionsButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),

        ])
    }

    private func configureButtonMenu(for team: Team) {
        teamOptionsButton.menu = MenuProvider.getTeamProfileOptionsMenu(for: team, delegate: teamOptionsDelegate)
    }

    func configureCell(team: Team) {
        self.team = team
        teamIcon.image = team.getTeamIcon(reduceTo: CGSize(width: 60, height: 60))

        let teamName = NSMutableAttributedString(string: team.teamName ?? "---", attributes: [
            .font: UIFont.systemFont(ofSize: GlobalConstants.Device.isIpad ? 28 : 24, weight: .bold),
            .foregroundColor: UIColor.label,
        ])

        let teamCreatedAt = NSMutableAttributedString(string: "\n\(team.teamMembers.count + team.teamAdmins.count + 1) Members\nCreated on \(team.teamCreatedAt!.convertToString())", attributes: [
            .font: UIFont.systemFont(ofSize: GlobalConstants.Device.isIpad ? 17 : 13),
            .foregroundColor: UIColor.secondaryLabel,
        ])

        teamName.append(teamCreatedAt)
        teamNameLabel.attributedText = teamName
        if team.isSelected {
            teamIcon.layer.borderWidth = 2
            teamIcon.layer.borderColor = UIColor.systemGreen.cgColor
        }
        configureButtonMenu(for: team)
    }

}
