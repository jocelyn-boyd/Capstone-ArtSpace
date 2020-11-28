//
//  FavoritesViewController.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 2/6/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class SavedArtViewController: UIViewController {
  
  //MARK: Properties
  var artObjectData = [ArtObject]() {
    didSet {
      self.savedArtCollectionView.reloadData()
    }
  }
  
  //MARK: UI Objects
  lazy var savedArtCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    
    let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: layout)
    collection.register(SavedArtCollectionViewCell.self, forCellWithReuseIdentifier: SavedArtCollectionViewCell.reuseIdentifier)
    collection.backgroundColor = .clear
    collection.dataSource = self
    collection.delegate = self
    return collection
  }()
  
  //MARK: Lifecyle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewBackgroundColor()
    setupNavigationBar()
    setupSavedArtCollectionView()
    loadAllBookmarkedArt()
    setupEmptyDataSourceDelegate()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadAllBookmarkedArt()
  }
  
  //MARK: Private Functions
  private func setupViewBackgroundColor() {
    UIUtilities.setViewBackgroundColor(view)
  }
  
  private func setupNavigationBar() {
    let viewControllerTitle = "Saved Artworks"
    let attrs = [
      NSAttributedString.Key.foregroundColor: UIColor(red: 35/255, green: 46/255, blue: 33/255, alpha: 1),
      NSAttributedString.Key.font: UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 25)]
    
    navigationController?.navigationBar.titleTextAttributes = attrs as [NSAttributedString.Key : Any]
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.view.backgroundColor = .clear
    navigationController?.navigationBar.topItem?.title = "\(viewControllerTitle)"
  }
  
  private func makeGeneralAlert(with title: String, message: String) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alertVC, animated: true, completion: nil)
  }
  
  private func makeConfirmationAlert(with title: String, and message: String) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
      self.loadAllBookmarkedArt()
    }))
    present(alertVC, animated: true, completion: nil)
  }
  
  private func loadAllBookmarkedArt() {
    FirestoreService.manager.getAllSavedArtObjects { (result) in
      switch result {
      case .failure(let error):
        self.makeGeneralAlert(with: "Error", message: "\(error)")
      case .success(let savedArtObjects):
        DispatchQueue.main.async {
          self.artObjectData = savedArtObjects
        }
      }
    }
  }
  
  private func setupSavedArtCollectionView() {
    view.addSubview(savedArtCollectionView)
    
    savedArtCollectionView.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.left.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
      make.right.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

//MARK: - UICollectionView Extension
extension SavedArtViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 25
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width - 50, height: view.safeAreaLayoutGuide.layoutFrame.width - 50)
  }
}

extension SavedArtViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return artObjectData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = savedArtCollectionView.dequeueReusableCell(withReuseIdentifier: SavedArtCollectionViewCell.reuseIdentifier, for: indexPath) as? SavedArtCollectionViewCell else {return UICollectionViewCell()}
    
    let savedArtObjects = artObjectData[indexPath.row]
    let url = URL(string: savedArtObjects.artImageURL)
    cell.savedImageView.kf.setImage(with: url)
    
    cell.artistNameLabel.text = "Artist: \(savedArtObjects.artistName)"
    cell.titleLabel.text = " "
    
//    let price = savedArtObjects.price
//    let formattedPrice = String(format: "$ %.2f", price)
//    cell.priceLabel.text = formattedPrice
//    cell.updateSoldStatus(status: savedArtObjects.soldStatus)
    
    cell.delegate = self
    cell.tag = indexPath.row
    return cell
  }
}

extension SavedArtViewController: UICollectionViewDelegate {
  //
}

//MARK: SavedArtCell Delegate Extension
extension SavedArtViewController: SavedArtCellDelegate {
  func buyButtonPressed(tag: Int) {
    let artObject = artObjectData[tag]
    let detailVC = ArtDetailViewController()
    detailVC.currentArtObject = artObject
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func removeSavedArt(tag: Int) {
    let alertVC = UIAlertController(title: "Remove Saved Item", message: "Are you sure?", preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
      let oneArtObject = self.artObjectData[tag]
      //MARK: TODO: Get Favorites from userID when authentication is implemented
      FirestoreService.manager.removeSavedArtObject(artID: oneArtObject.artID) { (result) in
        switch result {
        case .failure(let error):
          self.makeConfirmationAlert(with: "Error removing saved item", and: "\(error)")
        case .success(()):
          DispatchQueue.main.async {
            self.loadAllBookmarkedArt()
            
          }
        }
      }
    }))
    present(alertVC, animated: true, completion: nil)
  }
}


extension SavedArtViewController: EmptyDataSetSource, EmptyDataSetDelegate {
  
  func setupEmptyDataSourceDelegate() {
    savedArtCollectionView.emptyDataSetDelegate = self
    savedArtCollectionView.emptyDataSetSource = self
    savedArtCollectionView.backgroundView = UIView()
  }
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let titleString = "You haven't saved any artworks yet."
    let titleAttributes = [NSAttributedString.Key.font: UIFont.init(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 25)]
    return NSAttributedString(string: titleString, attributes: titleAttributes)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let descriptionString = "Tap the heart on an artwork to save for later."
    let descriptionAttributes = [NSAttributedString.Key.font: UIFont.init(descriptor: .preferredFontDescriptor(withTextStyle: .subheadline), size: 20)]
    return NSAttributedString(string: descriptionString, attributes: descriptionAttributes)
  }
  
}
