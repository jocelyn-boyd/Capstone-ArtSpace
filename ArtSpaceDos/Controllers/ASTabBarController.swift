//
//  MainTabVC.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 2/6/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit


class ASTabBarController: UITabBarController {
    
    //MARK: Properties
    lazy var home = UINavigationController(rootViewController: HomeViewController())
    lazy var bookmark = UINavigationController(rootViewController: SavedArtViewController())
    lazy var profile = UINavigationController(rootViewController: ProfileViewController())
    lazy var createPost = UINavigationController(rootViewController: CreatePostViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabItems()
    }
    
    private func setTabItems() {
        home.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), tag: 0)
        createPost.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.rectangle.portrait"), tag: 1)
        bookmark.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bookmark.fill"), tag: 2)
        profile.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), tag: 3)
        viewControllers  = [home, createPost, bookmark, profile]
    }
}
