//
//  TaskTitleCellTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 11/04/23.
//

import UIKit

class TaskTitleCell: UITableViewCell {

    static let identifier = "TaskTitleCell"

    lazy var titleLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.type = .continuous
        label.numberOfLines = 1
        label.contentMode = .center
        label.speed = .rate(40)
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    private func configureCellView() {
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }

    func configureTitle(_ title: String) {
        titleLabel.text = title + String.init(repeating: " ", count: 20)
    }

}
