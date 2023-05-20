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
    
    override func prepareForReuse() {
        self.cellTextLabel.attributedText = nil
        self.cellImageView.image = nil
        self.cellTextLabel.text = nil
        accessoryType = .none
        accessoryView = nil
    }

    func configureCellData(text: String, image: UIImage? = nil) {
        self.cellTextLabel.attributedText = NSMutableAttributedString(string: text)
        self.cellImageView.image = image
    }
    
    func setImage(image: UIImage? = nil) {
        self.cellImageView.image = image
    }
    
    func setTitle(_ string: String, withHighLightRange range: NSRange? = nil) {
        self.cellTextLabel.text = nil
        
        let attributedString = NSMutableAttributedString(string: string)
        if let range = range, range.location != NSNotFound {
//            attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
            attributedString.addAttribute(.foregroundColor, value: GlobalConstants.Colors.accentColor, range: range)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17.7, weight: .bold), range: range)
        }
        self.cellTextLabel.attributedText = attributedString

    }
    
    func changeImage(_ image: UIImage?) {
        self.cellImageView.image = image
    }

    private func configureCellUI() {
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
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
            cellTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
