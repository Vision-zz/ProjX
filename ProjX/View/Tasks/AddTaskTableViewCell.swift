//
//  AddTaskTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class AddTaskTableViewCell: UITableViewCell {

    static let identifier = "AddTaskTableViewCell"

    lazy var keyLabel: PROJXLabel = {
        let label = PROJXLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = GlobalConstants.Colors.tertiaryBackground
        label.textColor = .secondaryLabel
        label.insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 8)
        label.contentMode = .top
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 13)
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .systemGray.withAlphaComponent(0.05)
        label.numberOfLines = 0
        return label
    }()

    lazy var valueView: UIView = {
        let valueView = UIView()
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.backgroundColor = GlobalConstants.Colors.secondaryBackground
        return valueView
    }()

    lazy var separatorLine: UIView = {
        let sepView = UIView()
        sepView.translatesAutoresizingMaskIntoConstraints = false
        sepView.backgroundColor = .tertiarySystemFill
        return sepView
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
        super.prepareForReuse()
        keyLabel.text = nil
        for subView in valueView.subviews {
            subView.removeFromSuperview()
        }
    }

    private func configureCellView() {
        backgroundColor = GlobalConstants.Colors.secondaryBackground
        selectionStyle = .none
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueView)
        contentView.addSubview(separatorLine)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            keyLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            keyLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            keyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            valueView.topAnchor.constraint(equalTo: contentView.topAnchor),
            valueView.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            valueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            separatorLine.leadingAnchor.constraint(equalTo: valueView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: valueView.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: valueView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.3)
        ])
    }

    func configureCellView(key string: String, valueViewConfiguration: (UIView) -> Void) {
        keyLabel.text = string
        valueViewConfiguration(valueView)
    }

}
