//
//  TagButton.swift
//  ArtSpaceDos
//
//  Created by God on 3/9/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit

enum SystemImageNames: String {
    case paintbrush = "paintbrush"
    case camera = "camera"
    case pencil = "pencil.and.outline"
    case newMedia = "faceid"
}

class TagButton: UIButton {
    var selectedBackgroundColor = ArtSpaceConstants.artSpaceBlue
    var selectedImage = UIImage(systemName: "checkmark")
    var unselectedBackgroundColor: UIColor = .white
    var unselectedSystemImageName = ""
    var isFiltering: Bool?
    var tagIndex: Int!
    
    func setupTagButton(_ button: TagButton, title: String, systemName: String, target: Any?, action: Selector) {
        
        //Image & Title
        setTitle(title, for: .normal)
        setTitleColor(ArtSpaceConstants.artSpaceBlue, for: .normal)
        setImage(UIImage(systemName: systemName), for: .normal)
        
        //Color
        backgroundColor = .white
        tintColor = ArtSpaceConstants.artSpaceBlue
        
        //Frame
        frame = CGRect(x: 0, y: 0, width: 130, height: 40)
        layer.cornerRadius = frame.height / 2
        layer.shadowColor = UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        
        //Action
        addTarget(target, action: action, for: .touchUpInside)
        
    }
    
    func updateTagButton(_ button: TagButton, currentlyFiltering: Bool){
        setImage(selectedImage, for: .normal)
        backgroundColor = selectedBackgroundColor
        tintColor = .white
        setTitleColor(.white, for: .normal)
        isFiltering = currentlyFiltering
    }
                
    func revertTagButton (_ button: TagButton, tag: Int) {
        tintColor = ArtSpaceConstants.artSpaceBlue
        backgroundColor = .white
        setTitleColor(ArtSpaceConstants.artSpaceBlue, for: .normal)
        switch tag {
        case 0:
            setImage(UIImage(systemName: SystemImageNames.camera.rawValue), for: .normal)
        case 1:
            setImage(UIImage(systemName: SystemImageNames.paintbrush.rawValue), for: .normal)
        case 2:
            setImage(UIImage(systemName: SystemImageNames.pencil.rawValue), for: .normal)
        case 3:
            setImage(UIImage(systemName: SystemImageNames.newMedia.rawValue), for: .normal)
        default:
            print("Not changing the image")
        }
    }
}
