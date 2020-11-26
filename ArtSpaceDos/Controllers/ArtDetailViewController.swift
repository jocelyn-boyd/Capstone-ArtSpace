//
//  ArtDetailViewController.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 1/30/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ArtDetailViewController: UIViewController {
    
    //MARK: - Properties
    var currentArtObject: ArtObject!
    
    // MARK: - UI Objects
    lazy var artImageView: UIImageView = {
        let imageView = UIImageView()
        UIUtilities.setUpImageView(imageView, image: UIImage(imageLiteralResourceName: "noimage"), contentMode: .scaleAspectFill)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1).cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        imageView.layer.shadowOpacity = 0.9
        imageView.layer.shadowRadius = 4
        return imageView
    }()
    
    lazy var artDescription: UITextView = {
         let summary = UITextView()
         summary.textAlignment = .center
         summary.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
         summary.text = "Description Unavailable"
         summary.font = summary.font?.withSize(20)
         return summary
     }()
    
    lazy var dimensionsLabel: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "Size", size: 20, alignment: .center)
        return label
    }()
    
    lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "", size: 30, alignment: .center)
//        label.font = UIFont(name: "", size: <#T##CGFloat#>)
        return label
    }()
    
    lazy var priceNameLabel: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "", size: 20, alignment: .center)
        return label
    }()

        lazy var arLogo: UIImageView = {
            let Imagelogo = UIImageView()
            UIUtilities.setUpImageView(Imagelogo, image: #imageLiteral(resourceName: "ARKit-Badge"), contentMode: .scaleAspectFit)
           Imagelogo.backgroundColor = #colorLiteral(red: 0.4900177717, green: 0.5300267935, blue: 0.5836209655, alpha: 0.8659605369)
            Imagelogo.translatesAutoresizingMaskIntoConstraints = false
           Imagelogo.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arButtonTapped(_:)))
            Imagelogo.addGestureRecognizer(tapGesture)
            return Imagelogo
        }()
    
    lazy var buyNowButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        UIUtilities.setUpButton(button, title: "S A V E", backgroundColor: .clear, target: self, action: #selector(buyNowButtonPressed))
//        button.setTitle("Save", for: .normal)
       button.layer.cornerRadius = 15
         button.layer.borderWidth = 5.0
        button.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.addTarget(self, action: #selector(buyNowButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
 
    //MARK: - Obj-C Functions
    @objc func buyNowButtonPressed() {
        FirestoreService.manager.createFavoriteArtObject(artObject: currentArtObject) { (result) in
          switch result {
          case .failure(let error):
            print(error)
          case .success(()):
    let alertPopup = UIAlertController(title: "Successful", message: "Saved that to favorites", preferredStyle: .alert)
   //MARK: Go back to originalVC(Home)
    alertPopup.addAction(UIAlertAction(title: "okay", style: .default, handler: {(alert: UIAlertAction!) in
//        let mainVC = MainViewController()
self.navigationController?.popViewController(animated: true)
    }))
    
    self.present(alertPopup, animated: true, completion: nil)
          }
        }
    }
    // MARK: arButtonNavigation
    @objc func arButtonTapped(_ tapGesture: UITapGestureRecognizer) {
        let newViewController = ARViewController()
        newViewController.artObject = self.currentArtObject
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    
    
    //MARK:- Private func
    private func getArtPosts() {
        priceNameLabel.text = "Price: $\(currentArtObject.price)"
        let heighMeasurement = Measurement(value: Double(currentArtObject.height), unit: UnitLength.meters)
        let widthMeasurement = Measurement(value: Double(currentArtObject.width), unit: UnitLength.meters)
        let centimeterWidth = heighMeasurement.converted(to: .centimeters)
        let centimeterHeight = widthMeasurement.converted(to: .centimeters)
        dimensionsLabel.text = "Dimensions: H x \(centimeterHeight) W x \(centimeterWidth)"
        artistNameLabel.text = "Artist Name: \(currentArtObject.artistName)"
         let url = URL(string: currentArtObject.artImageURL)
        artImageView.kf.setImage(with: url)
        
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        UIUtilities.setViewBackgroundColor(view)
        addSubviews()
        setupUIConstraints()
        getArtPosts()
        
    }
    
    //MARK: - Private functions
    //MARK: TO DO - Pass data into the UI elements
    private func addSubviews() {
        view.addSubview(artImageView)
        view.addSubview(dimensionsLabel)
        view.addSubview(artistNameLabel)
//        view.addSubview(priceNameLabel)
        view.addSubview(arLogo)
//        view.addSubview(artDescription)
    }
    
    private func setupUIConstraints() {
        constrainDimensionLabel()
        constrainArtLabel()
//        constrainPriceLabel()
        constrainBuyButton()
        constrainARButton()
        constrainArtView()
//        descriptionConstraints()
    }
    
    // MARK: - Constraints
    private func constrainDimensionLabel() {
   dimensionsLabel.snp.makeConstraints { (make) in
    make.left.equalTo(artistNameLabel)
//    make.right.equalTo(self.view).offset(-8)
    make.height.equalTo(self.view)
    make.bottom.equalTo(self.view).offset(100)
    }
    } 
    
    private func constrainArtView() {
        artImageView.snp.makeConstraints{ make in
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view)
        }
    } 
    
    private func constrainArtLabel() {
        artistNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
//                make.right.equalTo(dimensionsLabel).offset(-8)
                make.height.equalTo(dimensionsLabel)
            make.bottom.equalTo(dimensionsLabel).offset(-30)
            }
    }

  
  private func  constrainBuyButton() {
    buyNowButton.snp.makeConstraints { make in
      make.centerY.equalTo(dimensionsLabel).offset(100)
      make.centerX.equalTo(self.view)
      make.width.equalTo(100)
    }
    
  }
  private func  constrainARButton() {
    arLogo.snp.makeConstraints { make in
      make.center.equalTo(view.center)
      make.bottom.equalTo(artImageView).offset(60)
      make.size.equalTo(CGSize(width: 80, height: 40))
    }
    
  }
  
  private func descriptionConstraints() {
    artDescription.snp.makeConstraints { (make) in
      make.left.equalTo(dimensionsLabel).offset(8)
      make.right.equalTo(dimensionsLabel).offset(-8)
      make.height.equalTo(arLogo)
      make.bottom.equalTo(arLogo).offset(40)
    }
    
  }
  
}
