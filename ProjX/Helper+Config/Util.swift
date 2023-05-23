//
//  Util.swift
//  ProjX
//
//  Created by Sathya on 26/03/23.
//

import UIKit

class Util {
    private init() { }

    public static func createGlassMorphicEffectView(for frame: CGRect? = nil) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let effect = UIVisualEffectView(effect: blurEffect)
        if let frame = frame { effect.frame = frame }
        return effect
    }

    public static func generateAlphanumericString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private static var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        gradientLayer.startPoint = CGPoint(x: 1.1, y: -1.4)
        gradientLayer.endPoint = CGPoint(x: 0.6, y: 0.73)
        return gradientLayer
    }()
    
    private static var renderer = UIGraphicsImageRenderer(size: CGRect(x: 0, y: 0, width: 200, height: 200).size)
    
    public static func generateInitialImage(from name: String) -> UIImage {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = GlobalConstants.Colors.accentColor.withAlphaComponent(0.35)
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 95)
        
        var initials = ""
        let initialsArray = name.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        if let firstWord = initialsArray.first, let firstLetter = firstWord.first {
            initials += String(firstLetter).capitalized
        }
        if initialsArray.count > 1, let lastWord = initialsArray.last, let lastLetter = lastWord.first {
            initials += String(lastLetter).capitalized
        }
        
        nameLabel.text = initials
        gradientLayer.colors = [GlobalConstants.Colors.accentColor.lighter(by: 0.66).cgColor, GlobalConstants.Colors.accentColor.cgColor]
        
        let nameImage = renderer.image { _ in
            gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            nameLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        return nameImage
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
    
    public static func cleanInputString(from string: String?) -> String? {
        guard let string = string else { return nil }
        let regex = try! NSRegularExpression(pattern: "(\\s)+", options: .caseInsensitive)
        let cleanedString = regex.stringByReplacingMatches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count),
            withTemplate: "$1"
        )
        return cleanedString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public static func findRange(of searchString: String, in mainString: String) -> NSRange? {
        let regex = try? NSRegularExpression(pattern: "\\b\(searchString)", options: .caseInsensitive)
        guard let regex = regex else { return nil }
        let range = NSRange(location: 0, length: mainString.utf16.count)
        let match = regex.firstMatch(in: mainString, options: [], range: range)
        guard let matchedRange = match?.range else { return nil }
        let startIndex = matchedRange.lowerBound
        let length = matchedRange.upperBound - startIndex
        return NSRange(location: startIndex, length: length)
        
    }

}
