//
//  PROJXLabel.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import UIKit

class PROJXLabel: UILabel {

    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += (insets.top + insets.bottom)
            contentSize.width += (insets.left + insets.right)
            return contentSize
        }
    }

}
