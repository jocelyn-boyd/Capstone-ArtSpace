//
//  FilterVC.swift
//  ArtSpaceDos
//
//  Created by God on 2/7/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class FilterViewController: UIViewController {
    //MARK: Variables
    weak var filterDelegate: FilterTheArtDelegate?
    
    var tagArray = [String]()
    //MARK: UI Elements
    
    lazy var popUpView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        UIUtilities.setViewBackgroundColor(view)
        view.layer.shadowColor = UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        view.layer.shadowOpacity = 0.9
        view.layer.shadowRadius = 4
        return view
    }()
    
    lazy var photographyTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Photography", systemName: "camera", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 0
        return button
    }()
    
    lazy var paintingTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Paintings", systemName: "paintbrush", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 1
        return button
    }()
    
    lazy var drawingTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Drawings", systemName: "pencil.and.outline", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 2
        return button
    }()
    
    lazy var newMediaTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "New Media", systemName: "faceid", target: self, action: #selector(addOrRemoveTags(_:)))
        button.tag = 3
        button.isFiltering = false
        return button
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        UIUtilities.setUpButton(button, title: "Filter", backgroundColor: ArtSpaceConstants.artSpaceBlue, target: self, action: #selector(filterPosts))
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.isUserInteractionEnabled = true
        return button
    }()
    
    lazy var resetPostsButton: UIButton = {
        let button = UIButton()
        UIUtilities.setUpButton(button, title: "Reset", backgroundColor: ArtSpaceConstants.artSpaceBlue, target: self, action: #selector(resetPosts))
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.isUserInteractionEnabled = true
        return button
    }()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(tagArray)
        ifAlreadyFiltered(filterButtons: [paintingTag,drawingTag,newMediaTag,photographyTag])
        view.backgroundColor = ArtSpaceConstants.artSpaceBlue.withAlphaComponent(0.50)
        view.isOpaque = false
        addSubViews(all: [popUpView,continueButton,resetPostsButton, photographyTag,paintingTag,drawingTag,newMediaTag])
        setUpConstraints()
    }
    
    //MARK: Private Functions
    func ifAlreadyFiltered(filterButtons: [TagButton]) {
        filterButtons.forEach({
//            $0.isFiltering! ? $0.updateTagButton($0, currentlyFiltering: true) : $0.revertTagButton($0, tag: $0.tag)
            if tagArray.contains($0.titleLabel!.text!) {
                $0.updateTagButton($0, currentlyFiltering: true)
            }
            else {
                $0.backgroundColor = .white
                $0.isSelected = false
            }
        })
    }
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: Objective C Functions
    //MARK: TO DO - Account for when button has already been selected
    @objc func addOrRemoveTags(_ sender: TagButton) {
        if sender.isFiltering! {
             guard tagArray.count > 0 else {
                            return
                        }
            guard let index = tagArray.firstIndex(where: {$0 == sender.titleLabel?.text}) else {
                return
            }
            tagArray.remove(at: index)
            sender.isFiltering = false
            sender.revertTagButton(sender, tag: sender.tag)
        }
        else {
            guard tagArray.contains(sender.titleLabel!.text!) else {
                            tagArray.append(sender.titleLabel!.text!)
                print(tagArray)
                sender.isFiltering = true
                            sender.updateTagButton(sender, currentlyFiltering: true)
                            return
                        }
            
        }
    }
    @objc func dismissFilterVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func filterPosts() {
        filterDelegate?.getTagsToFilter(get: tagArray)
        dismissFilterVC()
    }
    @objc func resetPosts() {
        filterDelegate?.cancelFilters()
        dismissFilterVC()
    }
    
    //MARK: Constraints
    func addSubViews(all views: [UIView]) {
        views.forEach({view.addSubview($0)})
    }
    
    func setUpConstraints() {
        
        photographyTag.snp.makeConstraints { make in
            make.top.equalTo(popUpView).offset(20)
            make.left.equalTo(popUpView).offset(20)
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
        
        paintingTag.snp.makeConstraints{ make in
            make.top.equalTo(photographyTag).offset(50)
            make.right.equalTo(popUpView).inset(20)
            make.width.equalTo(photographyTag)
            make.height.equalTo(photographyTag)
        }

        drawingTag.snp.makeConstraints{ make in
            make.top.equalTo(photographyTag).offset(100)
            make.height.equalTo(photographyTag)
            make.width.equalTo(photographyTag)
            make.left.equalTo(photographyTag)
        }

        newMediaTag.snp.makeConstraints{ make in
            make.top.equalTo(drawingTag).offset(50)
            make.height.equalTo(paintingTag)
            make.width.equalTo(paintingTag)
            make.right.equalTo(paintingTag)
        }
        
        resetPostsButton.snp.makeConstraints { make in
            make.bottom.equalTo(popUpView)
            make.width.equalTo(150)
            make.right.equalTo(popUpView)
            make.height.equalTo(50)
        }

        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(popUpView)
            make.width.equalTo(150)
            make.left.equalTo(popUpView)
            make.height.equalTo(50)
        }
        
        popUpView.snp.makeConstraints{ make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }


}
