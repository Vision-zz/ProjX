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
        self.view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}
