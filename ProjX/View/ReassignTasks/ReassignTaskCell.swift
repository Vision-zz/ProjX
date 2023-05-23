//
//  ReassignTeamTaskCell.swift
//  ProjX
//
//  Created by Sathya on 22/05/23.
//

import UIKit

class ReassignTaskCell: UITableViewCell {

    static let identifier = "ReassignTeamTaskCell"
    
    var team: Team! = nil
    weak var delegate: ReassignForWholeTeamDelegate? = nil
    
    lazy var assignToButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.title = "Assign All"
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = GlobalConstants.Colors.accentColor
        button.tintColor = .white
        button.addTarget(self, action: #selector(assignToButtonOnClick), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    lazy var cellTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var cellSecondaryTextlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 13.5)
        return label
    }()
    
    lazy var viewMoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "View"
        label.textColor = GlobalConstants.Colors.accentColor
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 12)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    override func prepareForReuse() {
        cellImageView.image = nil
        cellTextLabel.text = nil
        cellSecondaryTextlabel.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCellUI() {
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        contentView.addSubview(cellImageView)
        contentView.addSubview(cellTextLabel)
        contentView.addSubview(cellSecondaryTextlabel)
        contentView.addSubview(viewMoreLabel)
        contentView.addSubview(assignToButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.heightAnchor.constraint(equalToConstant: 30),
            cellImageView.widthAnchor.constraint(equalToConstant: 30),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            cellTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cellTextLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 10),
            cellTextLabel.trailingAnchor.constraint(equalTo: assignToButton.leadingAnchor, constant: -5),
            
            viewMoreLabel.centerYAnchor.constraint(equalTo: cellSecondaryTextlabel.centerYAnchor),
            viewMoreLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 10),
            
            cellSecondaryTextlabel.topAnchor.constraint(equalTo: cellTextLabel.bottomAnchor),
            cellSecondaryTextlabel.leadingAnchor.constraint(equalTo: viewMoreLabel.trailingAnchor, constant: 2.5),
            cellSecondaryTextlabel.trailingAnchor.constraint(equalTo: assignToButton.leadingAnchor, constant: -5),
            
            assignToButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            assignToButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    @objc private func assignToButtonOnClick() {
        delegate?.reassigned(for: team)
    }
    
    func configureCell(title: String, secondaryTitle: String, image: UIImage) {
        cellTextLabel.text = title
        cellSecondaryTextlabel.text = secondaryTitle
        cellImageView.image = image
    }
    
}
