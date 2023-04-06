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

    public static func validate(email: String) -> Bool {
        let emailRegex = /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/
        let match = email.firstMatch(of: emailRegex)
        if match == nil {
            return false
        }
        return true
    }

    public static func calculatePasswordComplexityPercentage(_ password: String) -> Double {
        let length = password.count
        var complexity: Double = 0

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
        for character in password {
            if characters.contains(character) {
                charCount += 1
            }
        }

        var complexityPercentage: Double = 0

        if length >= 2 {
            complexityPercentage += 2
        }
        if length >= 5 {
            complexityPercentage += 3
        }
        if length >= 8 {
            complexityPercentage += 10
        }
        if length >= 12 {
            complexityPercentage += 10
        }
        if length >= 16 {
            complexityPercentage += 15
        }
        if length >= 20 {
            complexityPercentage += 15
        }
        if complexity >= 1 {
            complexityPercentage += 7.5
        }
        if complexity >= 2 {
            complexityPercentage += 7.5
        }
        if complexity >= 3 {
            complexityPercentage += 7.5
        }
        if complexity == 4 {
            complexityPercentage += 7.5
        }

        if charCount >= 1 {
            complexityPercentage += 5
        }

        if charCount >= 3 {
            complexityPercentage += 5
        }

        if charCount >= 5 {
            complexityPercentage += 5
        }

        print(password, complexityPercentage)
        return complexityPercentage
    }

}
