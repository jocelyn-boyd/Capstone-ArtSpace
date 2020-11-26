//
//  ArtCell.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 1/30/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import SnapKit

class ArtCell: UICollectionViewCell {
    
    weak var delegate: ArtCellFavoriteDelegate?
    
    static let resuseIdentifier = String(describing: ArtCell.self)
    lazy var imageView = ASImageView()
    lazy var bookmarkButton = ASButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBookmarkButton()
        addSubViews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBookmarkButton() {
        let imageConfig = UIImage.SymbolConfiguration(scale: .large)
        bookmarkButton.backgroundColor = .white
        bookmarkButton.tintColor = .systemBlue
        bookmarkButton.setImage(UIImage(systemName: "bookmark", withConfiguration: imageConfig), for: .normal)
        bookmarkButton.layer.cornerRadius = CGFloat(integerLiteral: 10)
        bookmarkButton.layer.borderWidth = 1
        bookmarkButton.layer.borderColor = UIColor.systemGray.cgColor
        bookmarkButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
    }
    
    private func addSubViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(bookmarkButton)
    }
    
    private func addConstraints() {
        imageView.snp.makeConstraints{ make in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.bottom.equalTo(contentView)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-5)
            make.width.equalTo(44)
        }
    }
    
    @objc private func likeButtonPressed(sender: UIButton!) {
        delegate?.faveArtObject(tag: sender.tag)
        if bookmarkButton.image(for: .normal) == UIImage(systemName: "bookmark") {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
}
