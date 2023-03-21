//
//  Constants.swift
//  Enceladus
//
//  Created by Sathya on 16/03/23.
//

import Foundation
import UIKit

enum Constants {
    public enum Background {

        case primary, secondary

        public static func getColor(for colorType: Background) -> UIColor {
            switch colorType {
                case .primary:
                    return UIColor(named: "UIPrimaryBackground")!
                case .secondary:
                    return UIColor(named: "UISecondaryBackground")!
            }
        }
    }
}

