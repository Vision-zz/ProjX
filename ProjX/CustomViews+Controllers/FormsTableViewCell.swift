//
//  AddTaskTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 07/04/23.
//

import UIKit

class FormsTableViewCell: UITableViewCell {

    static let identifier = "AddTaskTableViewCell"

    lazy var keyLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 11.5)
        label.textContainer.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        label.textContainer.maximumNumberOfLines = 0
        return label
    }()

    lazy var keyView: UIView = {
        let keyView = UIView()
        keyView.translatesAutoresizingMaskIntoConstraints = false
        keyView.backgroundColor = .systemGray.withAlphaComponent(0.05)
        return keyView
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
        keyView.addSubview(keyLabel)
        contentView.addSubview(keyView)
        contentView.addSubview(valueView)
        contentView.addSubview(separatorLine)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            keyView.topAnchor.constraint(equalTo: self.topAnchor),
            keyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            keyView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25),
            keyView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            keyLabel.topAnchor.constraint(equalTo: keyView.topAnchor, constant: 8),
            keyLabel.leadingAnchor.constraint(equalTo: keyView.leadingAnchor),
            keyLabel.trailingAnchor.constraint(equalTo: keyView.trailingAnchor),
            keyLabel.bottomAnchor.constraint(equalTo: keyView.bottomAnchor),

            valueView.topAnchor.constraint(equalTo: self.topAnchor),
            valueView.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            valueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            separatorLine.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: valueView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.3)
        ])
    }

    func configureCellView(key string: String, valueViewConfiguration: (UIView) -> Void) {
        keyLabel.text = string
        valueViewConfiguration(valueView)
    }

}
