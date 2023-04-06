//
//  Constants.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import Foundation
import UIKit

enum GlobalConstants {

    enum Background {
        static var primary: UIColor { UIColor(named: "UIPrimaryBackground")! }
        static var secondary: UIColor { UIColor(named:"UISecondaryBackground")! }
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
