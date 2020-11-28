import UIKit
import SnapKit
import Kingfisher

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var artCollectionView = ASCollectionView()
    private var artObjectData = [ArtObject]() {
        didSet {
            self.artCollectionView.reloadData()
        }
    }
    
    private var currentFilters = [String]()
    private var isCurrentlyFiltered = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureCollectionView()
        loadUploadedPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUploadedPosts()
    }
    
    // MARK: - Private Methods
    private func loadUploadedPosts() {
        self.showActivityIndicator(shouldShow: true)
        FirestoreService.manager.getAllArtObjects { [weak self](result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let artFromFirebase):
                DispatchQueue.main.async {
                    self?.artObjectData = artFromFirebase
                    self?.showActivityIndicator(shouldShow: false)
                }
            }
        }
    }
        
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Objc Methods
    @objc func transitionToFilterVC() {
        let popUpVC = FilterViewController()
        popUpVC.modalPresentationStyle = .overCurrentContext
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.filterDelegate = self
        if isCurrentlyFiltered {
            popUpVC.tagArray = currentFilters
        } else {
            popUpVC.tagArray = [String]()
        }
        self.navigationController?.present(popUpVC, animated: true, completion: nil)
    }
    
    @objc private func transitionToCreatePostVC() {
        let createPost = CreatePostViewController()
        navigationController?.present(createPost, animated: true, completion: nil)
    }
    
    // MARK: - Configuration Methods
    private func configureNavigationBar() {
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(transitionToFilterVC))
        navigationItem.rightBarButtonItem = filterButton
        navigationController?.navigationBar.topItem?.title = "ArtSpace"
    }
    
    private func configureCollectionView() {
        artCollectionView.delegate = self
        artCollectionView.dataSource = self
        artCollectionView.register(ArtCell.self, forCellWithReuseIdentifier: ArtCell.resuseIdentifier)
        UIUtilities.setViewBackgroundColor(artCollectionView)
        
        view.addSubview(artCollectionView)
        artCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - UICollectionView Protocol Extension
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artObjectData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = artCollectionView.dequeueReusableCell(withReuseIdentifier: ArtCell.resuseIdentifier, for: indexPath) as? ArtCell else {return UICollectionViewCell()}
        let currentCell = artObjectData[indexPath.row]
        let url = URL(string: currentCell.artImageURL)
        
        cell.imageView.kf.setImage(with: url)
        cell.delegate = self
        cell.bookmarkButton.tag = indexPath.row
        
        let _ = currentCell.existsInFavorites { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let bool):
                switch bool {
                case true:
                    cell.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                case false:
                    cell.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                }
            }
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let specificArtObject = artObjectData[indexPath.row]
        let detailVC = ArtDetailViewController()
        detailVC.currentArtObject = specificArtObject
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells: CGFloat = 2
        let numSpaces: CGFloat = numCells + 1
        
        let screenWidth = UIScreen.main.bounds.width
        let screenheight = UIScreen.main.bounds.height
        
        return CGSize(width: (screenWidth - (5.0 * numSpaces)) / numCells, height: screenheight / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

// MARK: - Custom Delegate Protocol Extension
// MARK: TODO - Refactor method to not call to Firebase to resfresh the view
extension HomeViewController: FilterTheArtDelegate {
    func cancelFilters() {
        // Resets the filters by calling the original art objects from Firebase
        loadUploadedPosts()
        isCurrentlyFiltered = false
    }
    
    func getTagsToFilter(get tags: [String]) {
        loadFilteredPosts(tags: tags)
        // Assigns the tags filtering the collection view to a variable that will be passed back to the Filtering View Controller
        currentFilters = tags
        // A bool that determines whether on not the view Controller is filtered, will be passed back to filter view controller so that the user doesnt repeat filters
        isCurrentlyFiltered = true
    }
    
    func loadFilteredPosts(tags: [String]) {
        // Checking to make sure that there are tags to be filtered
        guard tags.count > 0 else {
            showAlert(with: "Oops!", and: "Please select a filter!")
            //Resets All Art If There Is No Filter
            loadUploadedPosts()
            return
        }
        // Filtering through the art object data based upon the tags selected
        artObjectData = artObjectData.filter({$0.tags.contains(tags[0].lowercased())
        })
    }
    
}

extension HomeViewController: ArtCellFavoriteDelegate {
    func faveArtObject(tag: Int) {
        let oneArtObject = artObjectData[tag]
        guard FirebaseAuthService.manager.currentUser != nil else { return }
        let _ = oneArtObject.existsInFavorites { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let bool):
                switch bool {
                case true:
                    // Uncomment the line below when user authorization is done to delete art by user.id
//                    FirestoreService.manager.deleteFavoriteArt(forUserID: user.uid, artID: oneArt.id
                    FirestoreService.manager.removeSavedArtObject(artID: oneArtObject.artID) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(()):
                            print("Remove bookmarked heart")
                        }
                    }
                case false:
                    FirestoreService.manager.createFavoriteArtObject(artObject: oneArtObject) { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(()):
                            print("Bookmarked heart")
                        }
                    }
                }
            }
        }
    }
}
