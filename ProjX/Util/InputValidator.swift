//
//  InputValidator.swift
//  ProjX
//
//  Created by Sathya on 20/03/23.
//

import Foundation

class InputValidator {


    public static func validate(username: String) -> Bool {
        let usernameRegex = /[^a-z0-9_]/
        let match = username.firstMatch(of: usernameRegex)
        if match != nil {
            return false
        }
        return true
    }

    func calculatePasswordComplexityPercentage(password: String) -> Int {
        let length = password.count
        var complexity = 0

        let uppercasePattern = "[A-Z]"
        if password.range(of: uppercasePattern, options: .regularExpression) != nil {
            complexity += 1
        }

        let lowercasePattern = "[a-z]"
        if password.range(of: lowercasePattern, options: .regularExpression) != nil {
            complexity += 1
        }

        let digitPattern = "[0-9]"
        if password.range(of: digitPattern, options: .regularExpression) != nil {
            complexity += 1
        }

        let specialCharacterPattern = "[^A-Za-z0-9]"
        if password.range(of: specialCharacterPattern, options: .regularExpression) != nil {
            complexity += 1
        }

        let characters = "!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/~`"
        var charCount = 0
        for character in characters {
            if password.contains(character) {
                charCount += 1
            }
        }

        var complexityPercentage = 0

        if length >= 8 {
            complexityPercentage += 10
        }
        if length >= 12 {
            complexityPercentage += 15
        }
        if length >= 16 {
            complexityPercentage += 15
        }
        if length >= 24 {
            complexityPercentage += 15
        }
        if complexity >= 3 {
            complexityPercentage += 15
        }
        if complexity == 4 {
            complexityPercentage += 15
        }

        if charCount > 3 {
            complexityPercentage += 5
        }

        if charCount > 5 {
            complexityPercentage += 10
        }

        return complexityPercentage
    }

}
