//
//  TeamPreviewVC.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class TeamPreviewVC: PROJXViewController {
        
    lazy var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.backgroundColor = .clear
        return shadowView
    }()
    
    lazy var teamIcon: UIImageView = {
        let teamIcon = UIImageView()
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        teamIcon.contentMode = .scaleAspectFill
        teamIcon.tintColor = .label
        teamIcon.layer.cornerRadius = 20
        teamIcon.layer.masksToBounds = true
        return teamIcon
    }()
    
    lazy var teamNameLabel: UILabel = {
        let teamNameLabel = UILabel()
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.textAlignment = .center
        teamNameLabel.numberOfLines = 1
        teamNameLabel.lineBreakMode = .byTruncatingTail
        teamNameLabel.textColor = .label
        teamNameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        return teamNameLabel
    }()
    
    lazy var teamInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        let path = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 20)
        shadowView.layer.shadowPath = path.cgPath
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    func configureView(for team: Team) {
        teamIcon.image = team.getTeamIcon()
        teamNameLabel.text = team.teamName ?? "---"
        
        let teamCreatedAt = NSMutableAttributedString(string: "\(team.teamMembers.count + team.teamAdmins.count + 1) Members\nCreated on \(team.teamCreatedAt!.convertToString())", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.secondaryLabel,
        ])
        teamInfoLabel.attributedText = teamCreatedAt
    }
    
    private func configureView() {
        view.backgroundColor = GlobalConstants.Colors.previewViewBackground
        view.addSubview(shadowView)
        view.addSubview(teamIcon)
        view.addSubview(teamNameLabel)
        view.addSubview(teamInfoLabel)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            shadowView.widthAnchor.constraint(equalToConstant: 100),
            shadowView.heightAnchor.constraint(equalToConstant: 100),
            
            teamIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            teamIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            teamIcon.widthAnchor.constraint(equalToConstant: 100),
            teamIcon.heightAnchor.constraint(equalToConstant: 100),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: teamIcon.bottomAnchor, constant: 20),
            teamNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            teamInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            teamInfoLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 10),
            teamInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
    }


}
