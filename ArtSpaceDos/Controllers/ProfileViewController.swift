//
//  ProfileViewController.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 2/6/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import FirebaseAuth
import Photos
import Firebase
import Kingfisher
import Stripe
class ProfileViewController: UIViewController {
    

   
    var displayNameHolder = "Display Name"
    var defaultImage = UIImage(systemName: "1")
    var settingFromLogin = false
    var photoLibraryAccess = true

  
    var imageURL: URL? = nil
    var savedImage = UIImage() {
        didSet {
            profileImage.image = savedImage
        }
    }

    
    //MARK: UI OBJC
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Welcome"
        label.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        return label
    }()
    
    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "1")
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        image.layer.borderWidth = 5.0
        var frame = image.frame
        frame.size.width = 150
        frame.size.height = 150
        image.frame = frame
        image.clipsToBounds = true
        image.backgroundColor = .white
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        image.layer.cornerRadius = image.frame.size.width/2
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(gesture)
        return image
    }()
    
    
    
    
    lazy var editDisplayNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Username", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(editDisplayNamePressed), for: .touchUpInside)
        return button
    }()
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter User Name"
        textField.font = UIFont(name: "Verdana", size: 14)
        textField.backgroundColor = .white
        //  textField.borderStyle = .bezel
        textField.layer.cornerRadius = 5
        textField.autocorrectionType = .no
        return textField
    }()
    
    lazy var uploadImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "icloud.and.arrow.up"), for: .normal)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        button.backgroundColor = .clear
        button.contentMode = .scaleAspectFill
        
        return button
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.hidesWhenStopped = true
        activityView.color = .white
        activityView.stopAnimating()
        return activityView
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.setTitle("Save Changes", for: .normal)
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var savePaymentInformation: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        UIUtilities.setUpButton(button, title: "Save Card", backgroundColor: .white, target: self, action: #selector(stripeSaveCard))
        button.layer.borderWidth = 2.0
               button.layer.cornerRadius = 15
               button.layer.borderColor = UIColor.systemBlue.cgColor
        button.isHidden = true
        return button
    }()
    
    
    //MARK: addSubviews
    func addSubviews() {
        view.addSubview(profileImage)
        // view.addSubview(uploadButton)
        view.addSubview(uploadImageButton)
        view.addSubview(saveButton)
        view.addSubview(userNameLabel)
        view.addSubview(textField)
        view.addSubview(editDisplayNameButton)
        view.addSubview(savePaymentInformation)
    }
    //MARK:ViewDidLoad cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainProfilePicture()
        saveChangesConstraints()
        constrainDisplayname()
        editUserNameConstraints()
        uploadImageConstraints()
        saveCardConstraints()
        if let displayName = FirebaseAuthService.manager.currentUser?.displayName {
            loadImage()
            userNameLabel.text = displayName
            
            let user = FirebaseAuthService.manager.currentUser
            imageURL = user?.photoURL
        }
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SignOut", style: .plain, target: self, action: #selector(signOutFunc))
        self.navigationController?.navigationBar.isHidden = false
        UIUtilities.setViewBackgroundColor(view)
        
    }

    //MARK: Private Functions
    private func setSceneDelegateInitialVC(with result: Result<User, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case.success(let user):
                print(user)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
                    else { return }
                
                if FirebaseAuthService.manager.currentUser != nil {
                    UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                        window.rootViewController = ASTabBarController()
                    }, completion: nil)
                    
                } else {
                    print("No current user")
                }
                
                
            case .failure(let error):
                self?.showAlert(with: "Error Creating User", and: error.localizedDescription)
            }
            
        }
    }
    
    private func formValidation() {
        let validUserName = userNameLabel.text != displayNameHolder
        let imagePresent = profileImage.image != defaultImage
        saveButton.isEnabled = validUserName && imagePresent
    }
    //MARK: Objc functions
    
    @objc func signOutFunc(){
      self.showActivityIndicator(shouldShow: true)
        FirebaseAuthService.manager.logoutUser()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
            else { return}
        
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
            
            window.rootViewController = LoginViewController()
        }, completion: {_ in
          self.showActivityIndicator(shouldShow: false)
        })
    }
    
    
    @objc func saveButtonPressed() {
        guard let userName = userNameLabel.text, let image = profileImage.image else {
            print("Defaults are not working")
            return
        }
        
        let validInput = (userName != displayNameHolder) && (image != defaultImage)
        
        if validInput {
            
            guard let imageUrl = imageURL else {
                print("Not able to compute imageUrl")
                return
            }
            
            FirebaseAuthService.manager.updateUserFields(userName: userName, photoURL: imageUrl) { (result) in
                switch result {
                case .success():
                    FirestoreService.manager.updateCurrentUser(userName: userName, photoURL: imageUrl) {  (result) in
                        switch result {
                        case .success(): break
                            
                        //  self?.transitionToMainFeed()
                        case .failure(let error):
                            print("Failure to update current user: \(error)")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            showErrorAlert(title: "Missing Requirements", message: "Profile needs a username and image")
        }
        
        
    }
    private func showErrorAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func stripeSaveCard() {
        let saveCardVC = SaveCardViewController()
        saveCardVC.modalPresentationStyle = .overCurrentContext
        present(saveCardVC, animated: true, completion: nil)
        
    }
    @objc private func profileImageTapped(){
        print("Pressed")
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined, .denied, .restricted:
            PHPhotoLibrary.requestAuthorization({[weak self] status in
                switch status {
                case .authorized:
                    self?.presentPhotoPickerController()
                case .denied:
                    print("Denied photo library permissions")
                default:
                    print("No usable status")
                }
            })
        default:
            presentPhotoPickerController()
        }
    }
    
    private func loadImage() {
        guard let imageUrl = FirebaseAuthService.manager.currentUser?.photoURL else {
            print("photo url not found")
            return
        }
        //King Fisher
        let url = URL(string:imageUrl.absoluteString)
        profileImage.kf.setImage(with: url)
        
        
    }
    
    private func presentPhotoPickerController() {
        DispatchQueue.main.async{
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = .photoLibrary
            imagePickerViewController.allowsEditing = true
            imagePickerViewController.mediaTypes = ["public.image", "public.movie"]
            self.present(imagePickerViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func updateButtonPressed(){
        guard let user = FirebaseAuthService.manager.currentUser else {return}
        guard let userName = user.displayName else {return}
        self.activityIndicator.startAnimating()
        FirestoreService.manager.updateCurrentUser(userName: userName) { (result) in
            switch (result) {
            case .success():
                self.activityIndicator.stopAnimating()
                self.showAlertWithSucessMessage()
            case .failure(let error):
                print(error)
            }
        }
        
        self.showAlert(with: "Error", and: "It seem your image was not save. Please check your image format and try again")
        
    }
    @objc func editDisplayNamePressed() {
        let alert = UIAlertController(title: "UserName", message: nil, preferredStyle: .alert)
        
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter UserName"
        }
        
        guard let userNameField = alert.textFields else {return}
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (alert) -> Void in
            
            self.userNameLabel.text = userNameField[0].text ?? self.displayNameHolder
            self.formValidation()
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    private func showAlertWithSucessMessage(){
        let alert = UIAlertController(title: "Success", message: "You have updated your profile", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (dismiss) in
            self.handleNavigationAwayFromVCAfterUpdating()
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    private func handleNavigationAwayFromVCAfterUpdating() {
        if settingFromLogin {
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: Constraints
    
    private func constrainProfilePicture() {
        profileImage.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(250)
            make.centerX.equalTo(self.view)
            make.height.equalTo(profileImage.frame.height)
            make.width.equalTo(profileImage.frame.width)
        }
    }
    private func constrainDisplayname() {
        userNameLabel.snp.makeConstraints { (make) in
            //   make.top.greaterThanOrEqualTo(profileImage).offset(-50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalTo(self.view)
        }
    }
    
    private func uploadImageConstraints() {
        uploadImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.profileImage).offset(125)
            make.trailing.equalTo(self.editDisplayNameButton).offset(15)
            
        }
    }
    
    private func saveChangesConstraints() {
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(editDisplayNameButton).offset(50)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(120)
        }
    }
    
    
    private func editUserNameConstraints() {
        editDisplayNameButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.profileImage).offset(100)
            make.centerX.equalTo(self.view)
        }
    }
 
    
    private func saveCardConstraints() {
        savePaymentInformation.snp.makeConstraints{ make in
            make.bottom.equalTo(saveButton).offset(50)
            make.centerX.equalTo(saveButton)
            make.width.equalTo(saveButton)
            make.height.equalTo(saveButton)
            
        }
    }
    
}

//MARK: Extension
extension ProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            return
        }
        
        self.savedImage = selectedImage
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.7) else {
            return
        }
        
        FirebaseStorageService.manager.storeImage(pictureType: .profilePicture, image: imageData, completion: { [weak self] (result) in
            switch result{
            case .success(let url):
                print("working")
                print(result)
                self?.imageURL = url
                
            case .failure(let error):
                print("Notworking")
                print(error)
            }
        })
        self.activityIndicator.stopAnimating()
        picker.dismiss(animated: true, completion: nil)
    }
}


