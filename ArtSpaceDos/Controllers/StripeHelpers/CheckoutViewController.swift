//
//  CheckoutViewController.swift
//  ArtSpaceDos
//
//  Created by God on 3/19/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class CheckoutViewController: UIViewController {
    
    var currentArtObject: ArtObject!
    
    lazy var artImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    lazy var titleText: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "Purchase This Art Peice", size: 20, alignment: .center)
        label.textColor = .white
        return label
    }()
    
    lazy var paymentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = ArtSpaceConstants.artSpaceBlue
        view.alpha = 1.0
        view.layer.shadowColor = UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        view.layer.shadowOpacity = 0.9
        view.layer.shadowRadius = 4
        return view
    }()
    
    lazy var shippingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 60))
        UIUtilities.setUpButton(button, title: "Shipping Address", backgroundColor: .clear, target: self, action: #selector(saveShippingInformation))
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var choosePaymentOption: UIButton = {
         let button = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 60))
        UIUtilities.setUpButton(button, title: "Choose Payment", backgroundColor: .clear, target: self, action: #selector(choosePayment))
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var buyNowButton: UIButton = {
       let button = UIButton()
        UIUtilities.setUpButton(button, title: "Purchase", backgroundColor: .clear, target: self, action: #selector(purchaseItem))
        button.setTitleColor(.white, for: .normal)
    return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        constraints()
        currentArtObject = ArtObject(artistName: "Adam", artDescription: "Buddha", width: 0.0, height: 0.0, artImageURL: "https://firebasestorage.googleapis.com/v0/b/artspaceprototype.appspot.com/o/1513295535487.jpg?alt=media&token=0f592691-a4c8-4a4e-b7d5-6c7e4ebed445", sellerID: "", price: 20.05, dateCreated: nil, tags: ["Painting"])
        let url = URL(string: currentArtObject.artImageURL)
        artImage.kf.setImage(with: url)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)


    }
    
    private func addSubViews() {
        UIUtilities.addSubViews([paymentView,shippingButton,choosePaymentOption,titleText,artImage, buyNowButton], parentController: self)
    }
    
    @objc func saveShippingInformation() {
        let shippingAddress = ShippingAddressViewController()
        shippingAddress.modalPresentationStyle = .overCurrentContext
        present(shippingAddress, animated: true, completion: nil)
    }
    
    @objc func choosePayment() {
        let paymentController = PaymentOptionsViewController()
        paymentController.modalPresentationStyle = .overCurrentContext
        present(paymentController, animated: true, completion: nil)
    }
    
    @objc func purchaseItem() {
        print("Item Purchased")
    }
    
    private func constraints() {
        
        titleText.snp.makeConstraints{ make in
            make.top.equalTo(paymentView)
            make.centerX.equalTo(paymentView)
            
        }
        
        shippingButton.snp.makeConstraints{ make in
            make.top.equalTo(paymentView).offset(175)
            make.left.equalTo(paymentView).offset(10)
        }
        
        choosePaymentOption.snp.makeConstraints{ make in
            make.top.equalTo(shippingButton).offset(50)
            make.left.equalTo(shippingButton)
            
        }
        
        buyNowButton.snp.makeConstraints{ make in
            make.top.equalTo(choosePaymentOption).offset(75)
            make.centerX.equalTo(paymentView)
            
        }
        
        paymentView.snp.makeConstraints{ make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.height.equalTo(view).dividedBy(1.5)
            make.width.equalTo(300)
        }
        
    }
}

