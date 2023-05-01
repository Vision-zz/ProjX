//
//  Constants.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import Foundation
import UIKit

enum GlobalConstants {

    enum Colors {

        enum AccentColor: String, CaseIterable {
            case boysenberry = "Boysenberry"
            case cloverGreen = "Clover Green"
            case cranverry = "Cranberry"
            case defaultAccent = "Default Blurple"
            case dolphin = "Dolphin"
            case havelockBlue = "Havelock Blue"
            case jadeGreen = "Jade Green"
            case lavender = "Lavender"
            case royalBlue = "Royal Blue"
            case sandDune = "Sand Dune"
            case sunshade = "Sunshade"
            case topaz = "Topaz"
            case watermelon = "Watermelon"
            case system = "System Blue"
        }

        static var primaryBackground: UIColor { UIColor(named: "UIPrimaryBackground")! }
        static var secondaryBackground: UIColor { UIColor(named:"UISecondaryBackground")! }
        static var tertiaryBackground: UIColor { UIColor(named: "UITertiaryBackground")! }
        static var accentColor: UIColor {
            let selection = UserDefaults.standard.string(forKey: UserDefaultsKey.selectedAccentColor) ?? AccentColor.defaultAccent.rawValue
            if selection == AccentColor.system.rawValue {
                return .systemBlue
            }
            let option = AccentColor.init(rawValue: selection) ?? .defaultAccent
            return UIColor(named: option.rawValue) ?? UIColor(named: AccentColor.defaultAccent.rawValue)!
        }

        static var accentColorString: String {
            let selection = UserDefaults.standard.string(forKey: UserDefaultsKey.selectedAccentColor) ?? AccentColor.defaultAccent.rawValue
            return selection
        }

        static func getAccentColor(named color: AccentColor) -> UIColor {
            if color == .system {
                return .systemBlue
            }
            return UIColor(named: color.rawValue) ?? UIColor(named: AccentColor.defaultAccent.rawValue)!
        }
    }

    enum Device {

        enum SelectedTheme: Int {
            case system = 0
            case light = 1
            case dark = 2
        }

        static var isIpad: Bool {
            return UIView().traitCollection.horizontalSizeClass == .regular && UIView().traitCollection.verticalSizeClass == .regular
        }

        static var selectedTheme: SelectedTheme {
            let option = UserDefaults.standard.integer(forKey: UserDefaultsKey.selectedTheme)
            return SelectedTheme.init(rawValue: option) ?? .system
        }
    }

    enum UserDefaultsKey {
        static let currentLoggedInUserID = "CURRENT_LOGGED_IN_USER_ID"
        static let selectedTheme = "SELECTED_THEME"
        static let selectedAccentColor = "SELECTED_ACCENT_COLOR"
    }

    enum StructureDelegates {
        static var appDelegate: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }
        static var sceneDelegate: SceneDelegate? { UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate }
    }

}
