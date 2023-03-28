//
//  TeamProfileCell.swift
//  ProjX
//
//  Created by Sathya on 27/03/23.
//

import UIKit

class TeamProfileCell: UITableViewCell {
    
    static let identifier = "TeamProfileCell"

    lazy var team: Team! = nil
    lazy var teamExitHandler: (() -> Void)? = nil

    lazy var teamIcon: UIImageView = {
        let teamIcon = UIImageView()
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        teamIcon.clipsToBounds = true
        teamIcon.contentMode = .scaleAspectFit
        teamIcon.tintColor = .label
        return teamIcon
    }()

    lazy var teamNameLabel: UILabel = {
        let teamNameLabel = UILabel()
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.textAlignment = .center
        teamNameLabel.numberOfLines = 1
        teamNameLabel.font = .systemFont(ofSize: 19, weight: .bold)
        teamNameLabel.lineBreakMode = .byTruncatingTail
        teamNameLabel.textColor = .label
        return teamNameLabel
    }()

    lazy var config: UIButton.Configuration = {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 3
        config.buttonSize = .mini
        return config
    }()

    lazy var leaveButton: UIButton = {
        let leaveButton = UIButton()
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.addTarget(self, action: #selector(leaveButtonOnClick), for: .touchUpInside)
        leaveButton.configuration = config
        leaveButton.backgroundColor = UIColor(hex: 0xea3131)
        leaveButton.tintColor = .white
        leaveButton.layer.cornerRadius = 17.5
        leaveButton.layer.shadowColor = UIColor.black.cgColor
        leaveButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        leaveButton.layer.shadowOpacity = 0.6
        return leaveButton
    }()

    lazy var selectButton: UIButton = {
        let selectButton = UIButton()
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.addTarget(self, action: #selector(selectButtonOnClick), for: .touchUpInside)
        selectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        selectButton.setTitle("Select", for: .normal)
        selectButton.configuration = config
        selectButton.layer.cornerRadius = 17.5
        selectButton.tintColor = .white
        selectButton.layer.shadowColor = UIColor.black.cgColor
        selectButton.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        selectButton.layer.shadowOpacity = 0.6
        return selectButton
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
        self.contentView.addSubview(leaveButton)
        self.contentView.addSubview(selectButton)
   }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamIcon.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            teamIcon.heightAnchor.constraint(equalToConstant: 150),
            teamIcon.widthAnchor.constraint(equalToConstant: 150),
            teamIcon.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),

            teamNameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            teamNameLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.7),
            teamNameLabel.topAnchor.constraint(equalTo: teamIcon.bottomAnchor, constant: 5),

            leaveButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            leaveButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: -70),
            leaveButton.widthAnchor.constraint(equalToConstant: 120),
            leaveButton.heightAnchor.constraint(equalToConstant: 35),

            selectButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            selectButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 70),
            selectButton.widthAnchor.constraint(equalToConstant: 120),
            selectButton.heightAnchor.constraint(equalToConstant: 35),
        ])
    }

    @objc private func selectButtonOnClick(_ sender: UIButton) {
        SessionManager.shared.changeSelectedTeam(to: team)
        sender.isUserInteractionEnabled = false
        sender.backgroundColor = UIColor(hex: 0x4ab13e)
        sender.setTitle("Selected", for: .normal)
    }

    @objc private func leaveButtonOnClick(_ sender: UIButton) {
        teamExitHandler?()
    }

    func configureCell(team: Team, onExitHandler: @escaping () -> Void) {
        self.team = team
        self.teamExitHandler = onExitHandler
        teamIcon.image = team.teamIconImage
        teamNameLabel.text = team.teamName ?? "----"

        if let signedInUserID = SessionManager.shared.signedInUser?.userID, team.teamOwnerID == signedInUserID {
            leaveButton.setImage(UIImage(systemName: "trash"), for: .normal)
            leaveButton.setTitle("Delete", for: .normal)
        } else {
            leaveButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
            leaveButton.setTitle("Leave", for: .normal)
        }

        if SessionManager.shared.signedInUser?.selectedTeamID == team.teamID && SessionManager.shared.signedInUser?.selectedTeamID != nil {
            selectButton.setTitle("Selected", for: .normal)
            selectButton.backgroundColor = UIColor(hex: 0x63b15e)
            selectButton.isUserInteractionEnabled = false
        } else {
            selectButton.setTitle("Select", for: .normal)
            selectButton.backgroundColor = .systemBlue
            selectButton.isUserInteractionEnabled = true
        }
    }

}
