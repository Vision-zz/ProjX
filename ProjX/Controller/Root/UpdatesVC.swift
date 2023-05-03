//
//  UpdatesVC.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class UpdatesVC: PROJXViewController {

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return false
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        title = "Updates"
    }
    
}
