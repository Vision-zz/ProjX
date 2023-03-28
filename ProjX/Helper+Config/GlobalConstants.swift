//
//  Constants.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import Foundation
import UIKit

enum GlobalConstants {
    public enum Background: String {
        case primary = "UIPrimaryBackground"
        case secondary = "UISecondaryBackground"
        case shadow = "UIShadow"

        public static func getColor(for colorType: Background) -> UIColor {
            return UIColor(named: colorType.rawValue)!
        }
    }

    enum Device {
        static var isIpad: Bool {
            return UIView().traitCollection.horizontalSizeClass == .regular && UIView().traitCollection.verticalSizeClass == .regular
        }
    }

    enum UserDefaultsKey {
        static let currentLoggedInUserID = "CURRENT_LOGGED_IN_USER_ID"
    }

}
