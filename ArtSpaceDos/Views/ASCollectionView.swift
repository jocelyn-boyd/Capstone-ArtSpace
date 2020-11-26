//
//  ASCollectionView.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 11/25/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit

class ASCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        UICollectionViewFlowLayout().scrollDirection = .vertical
        UICollectionViewFlowLayout().itemSize = CGSize(width: 250, height: 250)
    }
}
