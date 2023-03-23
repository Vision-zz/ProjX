//
//  HomeCollectionViewHeaderView.swift
//  ProjX
//
//  Created by Sathya on 22/03/23.
//

import UIKit

class HomeCollectionViewHeaderView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBaseUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureBaseUI() {
        self.backgroundColor = .systemRed
    }

}
