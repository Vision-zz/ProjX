//
//  PROJXImageTextCellTableViewCell.swift
//  ProjX
//
//  Created by Sathya on 31/03/23.
//

import UIKit

class PROJXImageTextCell: UITableViewCell {

    deinit {
        print("Deinit ImageTextCell")
    }

    static let identifier = "PROJXImageTextCell"

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCellData(text: String, image: UIImage? = nil) {
        self.cellTextLabel.text = text
        self.cellImageView.image = image
    }

    private func configureCellUI() {
        self.backgroundColor = GlobalConstants.Background.secondary
        contentView.addSubview(cellImageView)
        contentView.addSubview(cellTextLabel)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.heightAnchor.constraint(equalToConstant: 30),
            cellImageView.widthAnchor.constraint(equalToConstant: 30),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),

            cellTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellTextLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 10),
        ])
    }
}
