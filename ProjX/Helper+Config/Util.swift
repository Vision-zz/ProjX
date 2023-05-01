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

    public static func generateInitialImage(from name: String) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = GlobalConstants.Colors.accentColor
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 90)
        var initials = ""
        let initialsArray = name.trimmingCharacters(in: CharacterSet(charactersIn: " ")).components(separatedBy: " ")
        if let firstWord = initialsArray.first {
            if let firstLetter = firstWord.first {
                initials += String(firstLetter).capitalized
            }
        }
        if initialsArray.count > 1, let lastWord = initialsArray.last {
            if let lastLetter = lastWord.first {
                initials += String(lastLetter).capitalized
            }
        }

        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }

    public static func downsampleImage(from data: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions)!
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampledOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels
        ] as [CFString : Any] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)
        guard let downsampledImage = downsampledImage else { return nil }
        return UIImage(cgImage: downsampledImage)
    }

    public static func configureCustomSelectionStyle(for cell: UITableViewCell, with color: UIColor = GlobalConstants.Colors.accentColor) {
        let selectedView = UIView()
        selectedView.backgroundColor = color.withAlphaComponent(0.15)
        cell.selectedBackgroundView = selectedView
        cell.multipleSelectionBackgroundView = selectedView
    }

}
