//
//  Util.swift
//  ProjX
//
//  Created by Sathya on 26/03/23.
//

import UIKit

class Util {
    private init() { }

    public static func createGlassMorphicEffectView(for frame: CGRect) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let effect = UIVisualEffectView(effect: blurEffect)
        effect.frame = frame
        return effect
    }

    public static func generateAlphanumericString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
