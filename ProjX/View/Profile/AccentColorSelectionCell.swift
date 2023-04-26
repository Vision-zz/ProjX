//
//  AccentColorSelectionCell.swift
//  ProjX
//
//  Created by Sathya on 24/04/23.
//

import UIKit

class AccentColorSelectionCell: UITableViewCell {

    static let identifier = "AccentColorSelectionCell"

    lazy var accentColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .trailing
        config.imagePadding = 5
        config.buttonSize = .small
        button.layer.borderWidth = 1.5
        button.backgroundColor = .clear
        button.layer.cornerRadius = 6
        button.setTitleColor(.label, for: .normal)
        button.layer.borderColor = GlobalConstants.Colors.accentColor.cgColor
        button.tintColor = GlobalConstants.Colors.accentColor
        button.setTitle(GlobalConstants.Colors.accentColorString, for: .normal)
        button.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: UIControl.State.normal)
        button.menu = configureMenu()
        button.showsMenuAsPrimaryAction = true
        button.configuration = config
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCellView() {
        var config = self.defaultContentConfiguration()
        config.text = "Accent Color"
        self.contentConfiguration = config

        contentView.addSubview(accentColorButton)

        NSLayoutConstraint.activate([
            accentColorButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accentColorButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

    }

    private func configureMenu() -> UIMenu {
        var children = [UIMenuElement]()
        for color in GlobalConstants.Colors.AccentColor.allCases {
            let image = UIImage(systemName: "circle.fill")!.withTintColor(GlobalConstants.Colors.getAccentColor(named: color), renderingMode: .alwaysOriginal)
            let isSelected = GlobalConstants.Colors.accentColorString == color.rawValue
            children.append(UIAction(title: color.rawValue, image: image, state: isSelected ? .on : .off, handler: { [weak self] _ in
                DataManager.shared.setSelectedAccentColor(color)
                self?.accentColorButton.layer.borderColor = GlobalConstants.Colors.accentColor.cgColor
                self?.accentColorButton.tintColor = GlobalConstants.Colors.accentColor
                self?.accentColorButton.setTitle(GlobalConstants.Colors.accentColorString, for: .normal)
            }))
        }

        let menu = UIMenu(options: [.singleSelection], children: children)
        return menu
    }

}
