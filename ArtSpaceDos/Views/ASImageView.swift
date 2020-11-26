//
//  ASImageView.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 11/25/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit

class ASImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
}
