//
//  BaseViewController.swift
//  Enceladus
//
//  Created by Sathya on 16/03/23.
//

import UIKit

class ELDSViewController: UIViewController {


    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        self.view.backgroundColor = Constants.Background.getColor(for: .primary)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}
