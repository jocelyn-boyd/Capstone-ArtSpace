//
//  profiletabViewController.swift
//  ArtSpaceDos
//
//  Created by Kary Martinez on 11/28/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import Foundation
import UIKit

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? UserProfileCell else {return UITableViewCell()}
        cell.backgroundColor = .clear
        
        switch indexPath.row {
        case 0:
            cell.title.text = "Saved Art"
            cell.cellIcon.setImage(UIImage(systemName: "bookmark"), for: .normal)
        
        case 1:
            cell.title.text = "Edit Username"
            cell.cellIcon.setImage(UIImage(systemName: "person.fill"), for: .normal)
        case 2:
            cell.title.text = "Post Your Own Art To Users"
            cell.cellIcon.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        case 3:
            cell.title.text = "Save Changes"
        default:
            print("")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let viewController = SavedArtViewController()
            present(viewController, animated: true, completion: nil)
        case 1:
           editDisplayNamePressed()
        case 2:
            print(" History")
        case 3:
            saveButtonPressed()
        case 4:
            let postController = SavedArtViewController()
            present(postController, animated: true, completion: nil)
        case 5:
            FirebaseAuthService.manager.logoutUser()
            let loginPage = LoginViewController()
            navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(loginPage, animated: true)
        default:
            print("")
        }
    }
    
    
}
