//
//  BaseViewController.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class PROJXViewController: UIViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return true
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        // Uncomment this line if you dont want any text to appear on the back buttons
        // self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "")
        self.view.backgroundColor = GlobalConstants.Colors.primaryBackground
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = GlobalConstants.Colors.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
//        tapGestureRecognizer.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
//    @objc private func onTap() {
//        view.endEditing(true)
//    }
}
