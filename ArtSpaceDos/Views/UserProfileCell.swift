//
//  UserProfileCell.swift
//  ArtSpaceDos
//
//  Created by Kary Martinez on 12/1/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//


import UIKit

class UserProfileCell: UITableViewCell {
    
    var currentItemId: Int?
    var parentViewController: UIViewController?
    
    lazy var recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "", size: 20, alignment: .center)
        label.textColor = ArtSpaceConstants.artSpaceBlue
        label.font = UIFont(name: "Avenir", size: 20)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    lazy var moreInformation: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "", size: 30, alignment: .center)
        label.textColor = .white
        label.font = UIFont(name: "Avenir", size: 30)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
               return label
    }()
    
    lazy var greenLayer: UIView = {
        let view = UIView()
        view.backgroundColor = ArtSpaceConstants.artSpaceBlue
        view.alpha = 0.30
        return view
    }()
    
    lazy var cellIcon: UIButton = {
        let button = UIButton()
        UIUtilities.setUpButton(button, title: "", backgroundColor: .clear, target: self, action: #selector(testFunction))
        button.tintColor = ArtSpaceConstants.artSpaceBlue
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          addSubviews()
          constraints()
        selectionStyle = .none
        layer.borderColor = ArtSpaceConstants.artSpaceBlue.cgColor
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      // MARK: - Lifecycle Functions
      override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
      }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func testFunction() {
        
    }

    private func addSubviews() {
        addSubview(title)
        addSubview(moreInformation)
        addSubview(cellIcon)
    }
    
    private func showAlert(with title: String, and message: String, parentController: UIViewController) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    private func constraints() {
        
        title.translatesAutoresizingMaskIntoConstraints = false
        moreInformation.translatesAutoresizingMaskIntoConstraints = false
        cellIcon.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            title.heightAnchor.constraint(equalToConstant: 30),
            title.topAnchor.constraint(equalTo: topAnchor,constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            moreInformation.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreInformation.leadingAnchor.constraint(equalTo: leadingAnchor),
            moreInformation.trailingAnchor.constraint(equalTo: trailingAnchor),
            moreInformation.heightAnchor.constraint(equalToConstant: self.frame.height / 0.5),
            moreInformation.topAnchor.constraint(equalTo: title.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
           cellIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
           
           cellIcon.topAnchor.constraint(equalTo: topAnchor,constant: 10)
            
        ])
    }

}
