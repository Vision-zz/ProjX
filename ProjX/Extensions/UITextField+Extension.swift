//
//  UITextField+Extension.swift
//  ProjX
//
//  Created by Sathya on 19/03/23.
//

import Foundation
import UIKit

extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }else{
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
    }

    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.tintColor = .secondaryLabel
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -16, bottom: 0, trailing: 0)
        button.configuration = config
        button.addTarget(self, action: #selector(togglePasswordView), for: .touchDown)
        self.rightView = button
        self.rightViewMode = .always
    }

    @objc fileprivate func togglePasswordView(_ sender: UIButton) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender)
    }

}
