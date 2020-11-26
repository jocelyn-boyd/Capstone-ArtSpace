
import UIKit
import SnapKit
import Photos
import AssetsLibrary

class CreatePostViewController: UIViewController {
    
    //MARK: - Properties
    var image = UIImage() {
        didSet {
            self.artImageView.image = image
        }
    }
    
    var imageURL: URL? = nil
    
    var currentUser: AppUser? = nil

    
    //MARK: - UIOjbects
    //MARK: TO DO - Add Text alignment to UI Utilities
    lazy var createPostLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Tell us about your art! Fill out the fields below."
        label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .subheadline), size: 18)
        return label
        
    }()
    
    lazy var artTitleTextfield: UITextField = {
        let textfield = UITextField()
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.textColor = .black
        textfield.textAlignment = .center
        textfield.attributedPlaceholder = NSAttributedString(string: "Name Of Art",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return textfield
    }()
    
    lazy var artPriceTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.textColor = .black
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        textField.attributedPlaceholder = NSAttributedString(string: "Price",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return textField
    }()
    
    lazy var dimensionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Dimensions (cm): "
        return label
    }()
    
    lazy var widthTexfield: UITextField = {
        let textfield = UITextField()
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.textColor = .black
        textfield.textAlignment = .center
        textfield.keyboardType = .decimalPad
        textfield.attributedPlaceholder = NSAttributedString(string: "width",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return textfield
    }()
    
    lazy var heightTextfield: UITextField = {
        let textfield = UITextField()
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.textColor = .black
        textfield.textAlignment = .center
        textfield.keyboardType = .decimalPad
        textfield.attributedPlaceholder = NSAttributedString(string: "height",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return textfield
    }()
    
    lazy var descriptionTextView: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.placeholder = "Artwork description goes here"
        textField.backgroundColor = .clear
        textField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Artwork description goes here",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        //MARK: TODO: Make a function to dismiss keyboard
        return textField
    }()
    
    lazy var artImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "icloud.and.arrow.down.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.black.cgColor
        return imageView
    }()
    
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(uploadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 5.0
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtilities.setViewBackgroundColor(view)
        setupNavigationBar()
        addSubviews()
        setUpConstraints()
        dismissKeyboardWithTap()
        getCurrentUser()
    }
    
    //MARK: - Obj-C Functions
    @objc func transitionOut() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func submitButtonPressed() {
        createArtObject()
    }
    
    @objc func uploadButtonPressed() {
        self.showActivityIndicator(shouldShow: true)
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //    MARK: - Private Functions
    
    private func getCurrentUser() {
        guard let user = FirebaseAuthService.manager.currentUser else {return}
        
        FirestoreService.manager.getCurrentAppUser(uid: user.uid) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let user):
                self.currentUser = user
                
            }
        }
        
    }
    
    private func dismissKeyboardWithTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func createArtObject(){
        guard let photoURL = imageURL else {return}
        let photoURLString = "\(photoURL)"
        
        guard self.currentUser != nil else {showAlert(with: "Error", and: "No valid user"); return}
               
        guard let artist = self.currentUser else {showAlert(with: "Error", and: "No valid user"); return}
        
        guard descriptionTextView.text != "", descriptionTextView.text != "", widthTexfield.text != "", heightTextfield.text != "", artPriceTextField.text != "" else {showAlert(with: "Error", and: "Fill out all fields"); return}
        
        guard let description = descriptionTextView.text, let widthString = widthTexfield.text, let heightString = heightTextfield.text, let priceString = artPriceTextField.text else {showAlert(with: "Error", and: "Invalid entry; check fields"); return}
        
        let priceDouble: Double? = Double((priceString as NSString).floatValue)
        let widthCGFloat: CGFloat? = CGFloat((widthString as NSString).floatValue)
        let heightCGFloat: CGFloat? = CGFloat((heightString as NSString).floatValue)
        
        if let price = priceDouble, let width = widthCGFloat, let height = heightCGFloat {
            guard price != 0.0, width != 0.0, height != 0.0 else {showAlert(with: "Error", and: "Invalid entry; check fields"); return}
            let newArtObject = ArtObject(artistName: artist.userName ?? "No artist name", artDescription: description, width: (width / 100) , height: (height / 100), artImageURL: photoURLString, sellerID: artist.uid, price: price, tags: ["2"])
            
            FirestoreService.manager.createArtObject(artObject: newArtObject) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                    self.showAlert(with: "Error", and: "Could not save item")
                case .success(()):
                    self.showAlert(with: "Art Posted", and: "Now Available For Sale!")
                }
            }
        } else {
            showAlert(with: "Error", and: "Invalid entry; check fields")
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        print("Submit Button Pressed. Data gets loaded intro Firebase")
    }
    
    private func setupNavigationBar() {
        let title = "Sell Your Art!"
        let attrs = [
            //MARK: TO DO - Get right font Avenir Next
            //MARK: To Do - Move navigation configurations to UI Utilities
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 25)]
        navigationController?.navigationBar.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.topItem?.title = "\(title)"
    }
 
    
    //MARK: UISetup
    func addSubviews() {
        [createPostLabel, artTitleTextfield,  artPriceTextField, dimensionsLabel, widthTexfield, heightTextfield, descriptionTextView, artImageView, uploadButton, submitButton].forEach({self.view.addSubview($0)})
    }
    
    //MARK: TO DO - Fix constraints
    func setUpConstraints() {
        
        createPostLabel.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            //            make.left.equalTo(view.safeAreaLayoutGuide).offset(25)
            //            make.right.equalTo(view.safeAreaLayoutGuide).offset(-25)
        }
        
        artTitleTextfield.snp.makeConstraints{ make in
            make.top.equalTo(createPostLabel).offset(50)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(25)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.height.equalTo(25)
        }
        
        artPriceTextField.snp.makeConstraints { make in
            make.top.equalTo(artTitleTextfield).offset(50)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(25)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.height.equalTo(25)
            
        }
        
        dimensionsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(artPriceTextField).offset(50)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(25)
            make.height.equalTo(25)
        }
        
        widthTexfield.snp.makeConstraints { (make) in
            make.top.equalTo(artPriceTextField).offset(50)
            make.right.equalTo(dimensionsLabel).offset(75)
            make.width.equalTo(75)
            make.height.equalTo(25)
        }
        
        heightTextfield.snp.makeConstraints { (make) in
            make.top.equalTo(artPriceTextField).offset(50)
            make.right.equalTo(widthTexfield).offset(100)
            make.width.equalTo(75)
            make.height.equalTo(25)
        }
        
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(widthTexfield).offset(50)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(25)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.height.equalTo(100)
        }
        
        artImageView.snp.makeConstraints{ make in
            make.top.equalTo(descriptionTextView).offset(125)
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        uploadButton.snp.makeConstraints{ make in
            make.top.equalTo(descriptionTextView).offset(150)
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(artImageView).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(100)
        }
    }
}

//MARK: - Extensions
extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        self.image = image
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {return}
        //MARK: To Do - Refactor when Image is being saved
        FirebaseStorageService.manager.storeImage(pictureType: .artPiece, image: imageData) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let url):
                self?.imageURL = url
            }
        }
                
        self.showActivityIndicator(shouldShow: false)

        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.showActivityIndicator(shouldShow: false)
        self.dismiss(animated: true, completion: nil)
    }
}
