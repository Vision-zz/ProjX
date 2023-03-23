//
//  ELDSCollectionViewController.swift
//  ProjX
//
//  Created by Sathya on 21/03/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class ELDSCollectionViewController: UICollectionViewController {

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
        self.view.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.collectionView.backgroundColor = GlobalConstants.Background.getColor(for: .primary)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}