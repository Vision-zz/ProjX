//
//  PROJXCollectionViewController.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class PROJXCollectionViewController: UICollectionViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var hidesBottomBarWhenPushed: Bool {
        get {
            return true
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
    }

    private func configureBaseUI() {
        self.view.backgroundColor = GlobalConstants.Colors.primaryBackground
        self.collectionView.backgroundColor = GlobalConstants.Colors.primaryBackground
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}
