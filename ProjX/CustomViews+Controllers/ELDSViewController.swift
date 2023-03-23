//
//  BaseViewController.swift
//  ProjX
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class ELDSViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        self.view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}
