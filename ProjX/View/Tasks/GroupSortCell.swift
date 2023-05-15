//
//  GroupSortCell.swift
//  ProjX
//
//  Created by Sathya on 04/05/23.
//

import UIKit

class GroupSortCell: UITableViewCell {
    
    static let identifier = "GroupSortCelll"

    private lazy var checkMark: UIImageView = {
        let checkMark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)))
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.tintColor = GlobalConstants.Colors.accentColor
        checkMark.isHidden = true
        checkMark.backgroundColor = .clear
        return checkMark
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var rightView: UIView = {
        let rightView = UIView()
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.backgroundColor = .clear
        return rightView
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
        checkMark.isHidden = true
        label.text = nil
        for subView in rightView.subviews {
            subView.removeFromSuperview()
        }
        accessoryView = nil
        accessoryType = .none
    }
    
    private func configureCellView() {
        Util.configureCustomSelectionStyle(for: self)
        separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        
        contentView.addSubview(checkMark)
        contentView.addSubview(label)
        contentView.addSubview(rightView)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            checkMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMark.heightAnchor.constraint(equalToConstant: 17),
            checkMark.widthAnchor.constraint(equalToConstant: 17),
            
            label.leadingAnchor.constraint(equalTo: checkMark.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: rightView.leadingAnchor),
            
            rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1)
        ])
    }
    
    func configureTitle(_ title: String) {
        label.text = title
    }
    
    func configureRightView(_ handler: (UIView) -> Void) {
        handler(rightView)
    }
    
    func setCheckmarkState(_ state: Bool) {
        checkMark.isHidden = !state
        rightView.isHidden = !state
    }
}
