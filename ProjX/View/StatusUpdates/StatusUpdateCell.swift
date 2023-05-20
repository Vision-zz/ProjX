//
//  StatusUpdateCell.swift
//  ProjX
//
//  Created by Sathya on 15/05/23.
//

import UIKit

class StatusUpdateCell: UITableViewCell {
    
    static let identifier = "StatusUpdateCellTableView"
    
    lazy var isCollapsed: Bool = true {
        didSet {
            configureCellForSelectedState()
        }
    }
    lazy var onExpandHandler: (() -> Void)? = nil
    lazy var associatedIndexpath: IndexPath? = nil
    weak var delegate: StatusUpdateCollapseDelegate? = nil
    
    private var buttonTransformAngle: CGFloat {
        return isCollapsed ? 0 : (CGFloat.pi / 2)
    }
    
    var cellHeight: CGFloat {
        isCollapsed ? 55 : (55 + descriptionLabel.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)).height + 10)
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .natural
        label.textColor = .label
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    private lazy var expandButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: buttonTransformAngle)
        button.tintColor = GlobalConstants.Colors.accentColor
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        isCollapsed = true
        associatedIndexpath = nil
        expandButton.transform = CGAffineTransform(rotationAngle: buttonTransformAngle)
    }
    
    private func configureCellView() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(expandButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.5),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 3),
            statusLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 11),
            
            descriptionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            expandButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            expandButton.widthAnchor.constraint(equalToConstant: 10),
            expandButton.heightAnchor.constraint(equalToConstant: 13),
            expandButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 21),
        ])
    }
    
    private func configureCellForSelectedState() {
        descriptionLabel.isHidden = isCollapsed
    }
    
    func configureCell(with statusUpdate: TaskStatusUpdate) {
        titleLabel.text = statusUpdate.subject
        statusLabel.text = "posted on \(statusUpdate.createdAt?.convertToString() ?? "Unknown")"
        descriptionLabel.text = statusUpdate.statusDescription
    }
    
    func setCellIsCollapsed(_ state: Bool) {
        guard isCollapsed != state else { return }
        isCollapsed = state
        animateButton()
    }
    
    func animateButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.expandButton.transform = CGAffineTransform(rotationAngle: self.buttonTransformAngle)
        })
    }
    
    func toggleCellCollapse() {
        guard let associatedIndexpath = associatedIndexpath else { return }
        setCellIsCollapsed(!isCollapsed)
        if isCollapsed {
            delegate?.cellCollapsed(atIndexPath: associatedIndexpath)
        } else {
            delegate?.cellExpanded(atIndexPath: associatedIndexpath)
        }
    }

}
