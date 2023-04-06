//
//  HomeCollectionViewEmptyPlaceholderCell.swift
//  ProjX
//
//  Created by Sathya on 22/03/23.
//

import UIKit

class HomeCollectionViewEmptyPlaceholderCell: UICollectionViewCell {

    static let identifier = "HomeCollectionViewEmptyPlaceholderCell"

    let largeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 23 : 20, weight: .semibold)
        return label
    }()

    let secondaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: GlobalConstants.Device.isIpad ? 17 : 14)
        label.alpha = 0.8
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureCellUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTitles(large: String, secondary: String) {
        largeLabel.text = large
        secondaryLabel.text = secondary
    }

    private func configureCellUI() {
        self.backgroundColor = GlobalConstants.Background.primary
        self.contentView.addSubview(largeLabel)
        self.contentView.addSubview(secondaryLabel)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            largeLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            largeLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -15),

            secondaryLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            secondaryLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 15)
        ])
    }

}
