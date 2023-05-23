//
//  TeamSelectButton.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class TeamSelectButton: UIButton {
    
    lazy var teamIcon: UIImageView = {
        let teamIcon = UIImageView()
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        teamIcon.clipsToBounds = true
        teamIcon.contentMode = .scaleAspectFill
        teamIcon.tintColor = GlobalConstants.Colors.accentColor
        teamIcon.layer.cornerRadius = 17.5
        return teamIcon
    }()
    
    convenience init() {
        self.init(frame: .null)
        configureView()
        configureConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        addSubview(teamIcon)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            teamIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            teamIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            teamIcon.heightAnchor.constraint(equalToConstant: 35),
            teamIcon.widthAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    func configureButton(for team: Team?) {
        teamIcon.tintColor = GlobalConstants.Colors.accentColor
        if let team = team {
            teamIcon.image = team.getTeamIcon(reduceTo: CGSize(width: 30, height: 30))
        } else {
            teamIcon.image = UIImage(systemName: "questionmark.circle.fill")
        }
    }
    
}
