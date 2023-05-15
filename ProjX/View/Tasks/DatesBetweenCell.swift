//
//  DatesBetweenCell.swift
//  ProjX
//
//  Created by Sathya on 11/05/23.
//

import UIKit

class DatesBetweenCell: UITableViewCell {
    
    static let identifier = "DatesBetweenCellForTableView"
    
    var isCellSelected: Bool = false {
        didSet {
            checkMark.isHidden = !isCellSelected
            configureCellForSelectedState()
        }
    }
    
    var selectedDates: DatesBetween {
        get {
            return DatesBetween(start: fromDatePicker.date, end: toDatePicker.date)

        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let contentSize = super.intrinsicContentSize
            let height: CGFloat = isCellSelected ? 100 : 44
            return CGSize(width: contentSize.width, height: height)
        }
    }
    
    private lazy var checkMark: UIImageView = {
        let checkMark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)))
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.tintColor = GlobalConstants.Colors.accentColor
        checkMark.isHidden = true
        checkMark.backgroundColor = .clear
        return checkMark
    }()
    
    lazy var keyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    lazy var fromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "From:"
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    lazy var toLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To:"
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    lazy var fromDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return datePicker
    }()
    
    lazy var toDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return datePicker
    }()
    
    lazy var toArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrowshape.right.fill"))
        imageView.tintColor = .systemFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureConstraints()
        configureCellForSelectedState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        isCellSelected = false
        keyLabel.text = nil
        accessoryView = nil
        accessoryType = .none
    }
    
    private func configureCellView() {
        Util.configureCustomSelectionStyle(for: self)
        separatorInset = UIEdgeInsets(top: 0, left: 33, bottom: 0, right: 0)
        selectionStyle = .none

        contentView.addSubview(checkMark)
        contentView.addSubview(keyLabel)
        contentView.addSubview(fromLabel)
        contentView.addSubview(fromDatePicker)
        contentView.addSubview(toLabel)
        contentView.addSubview(toDatePicker)
        contentView.addSubview(toArrow)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            
            checkMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            checkMark.centerYAnchor.constraint(equalTo: keyLabel.centerYAnchor),
            checkMark.heightAnchor.constraint(equalToConstant: 17),
            checkMark.widthAnchor.constraint(equalToConstant: 17),
            
            keyLabel.leadingAnchor.constraint(equalTo: checkMark.trailingAnchor, constant: 8),
            keyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            toArrow.heightAnchor.constraint(equalToConstant: 20),
            toArrow.widthAnchor.constraint(equalToConstant: 20),
            toArrow.centerYAnchor.constraint(equalTo: fromDatePicker.centerYAnchor),
            toArrow.leadingAnchor.constraint(equalTo: fromDatePicker.trailingAnchor, constant: 12),
            
            fromLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 5),
            fromLabel.leadingAnchor.constraint(equalTo: fromDatePicker.leadingAnchor, constant: 3),
            
            toLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 5),
            toLabel.leadingAnchor.constraint(equalTo: toDatePicker.leadingAnchor, constant: 3),
            
            fromDatePicker.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 3),
            fromDatePicker.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor),
            
            toDatePicker.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 3),
            toDatePicker.leadingAnchor.constraint(equalTo: toArrow.trailingAnchor, constant: 12),
        ])
    }
    
    private func configureCellForSelectedState() {
        let hiddenState = !isCellSelected
        fromLabel.isHidden = hiddenState
        toLabel.isHidden = hiddenState
        toArrow.isHidden = hiddenState
        fromDatePicker.isHidden = hiddenState
        toDatePicker.isHidden = hiddenState
    }
    
    func configureTitle(_ title: String) {
        keyLabel.text = title
    }
    
    func setIsCellSelected(_ state: Bool) {
        guard isCellSelected != state else { return }
        isCellSelected = state
    }
    
    func configureDefaultDateFor(fromDate: Date) {
        fromDatePicker.date = fromDate
    }
    
    func configureDefaultDateFor(toDate: Date) {
        toDatePicker.date = toDate
    }
}
