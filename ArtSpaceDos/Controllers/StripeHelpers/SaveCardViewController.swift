//
//  SaveCardViewController.swift
//  ArtSpaceDos
//
//  Created by God on 3/19/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import Stripe
import SnapKit

class SaveCardViewController: STPAddCardViewController {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "Save Your Card", size: 14, alignment: .center)
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        UIUtilities.setUpButton(button, title: "", backgroundColor: .clear, target: self, action: #selector(backToProfile))
        let image = UIImage(systemName: "chevron.left")
        button.setImage(image, for: .normal)
        return button
    }()
        lazy var saveCard: UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 60))
            UIUtilities.setUpButton(button, title: "Save Card", backgroundColor: ArtSpaceConstants.artSpaceBlue, target: self, action: #selector(pay))
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.shadowColor = UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 1
            return button
        }()
    
           @objc
           func pay() {
            print("Save Button Clicked")
               // Collect card details on the client
//               let cardParams = "cardTextField.cardParams"
//               let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
//               STPAPIClient.shared().createPaymentMethod(with: paymentMethodParams) { [weak self] paymentMethod, error in
//                   guard let paymentMethod = paymentMethod else {
//                       // Display the error to the user
//                       return
//                   }
//                   let paymentMethodId = paymentMethod.stripeId
//                   // Send paymentMethodId to your server for the next steps
//               }
           }
    
    @objc private func backToProfile() {
        dismiss(animated: true, completion: nil)
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(titleLabel)
            view.addSubview(saveCard)
            view.addSubview(backButton)
            constraints()
            view.backgroundColor = .white
            // Do any additional setup after loading the view.
        }
    
        private func constraints() {
            
            titleLabel.snp.makeConstraints{ make in
                make.centerX.equalTo(view)
                make.top.equalTo(view).offset(40)
            }
            
            backButton.snp.makeConstraints{ make in
                make.left.equalTo(titleLabel).offset(-50)
                make.centerY.equalTo(titleLabel)
                
                
            }
    
            saveCard.snp.makeConstraints{ make in
                make.centerY.equalTo(view).offset(50)
                make.centerX.equalTo(view)
                make.width.equalTo(120)
                make.height.equalTo(60)
            }
    
    
        }
    
    
}
