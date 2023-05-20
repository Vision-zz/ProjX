//
//  TasksHeaderView.swift
//  ProjX
//
//  Created by Sathya on 10/05/23.
//

import UIKit

class TasksHeaderView: UITableViewHeaderFooterView {

    weak var delegate: TaskSectionExpandDelegate?
    static let identifier = "TasksHeaderViewTableHeaderFooterView"
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.backgroundColor = .clear
        return label
    }()

    private var isCollapsed: Bool = false
    private var buttonTransformAngle: CGFloat {
        return isCollapsed ? 0 : (CGFloat.pi / 2)
    }
    
    lazy var associatedSection: Int = -1

    private lazy var expandButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: buttonTransformAngle)
        button.tintColor = GlobalConstants.Colors.accentColor
        return button
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        isCollapsed = false
        label.text = nil
        associatedSection = -1
        updateButtonTintColor()
        expandButton.transform = CGAffineTransform(rotationAngle: buttonTransformAngle)
    }

    private func configureCellView() {
        contentView.addSubview(label)
        contentView.addSubview(expandButton)
        var config = UIBackgroundConfiguration.listGroupedHeaderFooter()
        config.backgroundColor = .systemGroupedBackground
        isOpaque = true
        backgroundConfiguration = config
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        self.addGestureRecognizer(tap)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            expandButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            expandButton.widthAnchor.constraint(equalToConstant: 10),
            expandButton.heightAnchor.constraint(equalToConstant: 13),
            expandButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configureLabel(_ title: String) {
        label.text = title
    }

    func setHeaderIsCollapsed(_ state: Bool) {
        guard isCollapsed != state else { return }
        isCollapsed = state
        animateButton()
    }
    
    func animateButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.expandButton.transform = CGAffineTransform(rotationAngle: self.buttonTransformAngle)
        })
    }

    func updateButtonTintColor() {
        expandButton.tintColor = GlobalConstants.Colors.accentColor
    }
    
    @objc private func headerTapped() {
        if associatedSection < 0 { return }
        setHeaderIsCollapsed(!isCollapsed)
        if isCollapsed {
            delegate?.sectionCollapsed(associatedSection)
        } else {
            delegate?.sectionExpanded(associatedSection)
        }
    }

}
