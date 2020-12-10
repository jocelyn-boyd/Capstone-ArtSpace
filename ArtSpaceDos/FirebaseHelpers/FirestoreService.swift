//
//  FirebaseService.swift
//  ArtSpaceDos
//
//  Created by Jocelyn Boyd on 1/30/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import Foundation
import FirebaseFirestore

fileprivate enum FirestoreCollections: String {
    case AppUser
    case ArtObject
    case FavoriteArt
    
}
// MARK: - Add when we add search bar
enum SortingCriteria: String {
    case fromNewestToOldest = "dateCreated"
    var shouldSortDescending: Bool {
        switch self {
        case .fromNewestToOldest:
            return true
        }
    }
}

class FirestoreService {
    
    static let manager = FirestoreService()
    
    private let database = Firestore.firestore()
    
//    MARK: - AppUser Methods
    func createAppUser(user: AppUser, completion: @escaping (Result<(), Error>) -> ()) {
        var fields: [String: Any] = user.fieldsDict
        fields["dateCreated"] = Date()
        database.collection(FirestoreCollections.AppUser.rawValue).document(user.uid).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(()))
        }
    }
    
func updateCurrentUser(userName: String? = nil, photoURL: URL? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        guard let userID = FirebaseAuthService.manager.currentUser?.uid else {return}
        
        var updateFields = [String:Any]()
        if let user = userName {
            updateFields["userName"] = user
        }
        if let photo = photoURL {
                 updateFields["photoURL"] = photo.absoluteString
             }
        database.collection(FirestoreCollections.AppUser.rawValue).document(userID).updateData(updateFields) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(()))
        }
         
    }
    
func getCurrentAppUser(uid: String, completion: @escaping (Result<AppUser, Error>) -> ()) {
 database.collection(FirestoreCollections.AppUser.rawValue).document(uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, let data = snapshot.data() {
                let userID = snapshot.documentID
                let user = AppUser(from: data, id: userID)
                completion(.success(user!))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[AppUser], Error>) -> ()) {
       
            database.collection(FirestoreCollections.AppUser.rawValue).getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let users = snapshot?.documents.compactMap({ (snapshot) -> AppUser? in
                        let userID = snapshot.documentID
                        let user = AppUser(from: snapshot.data(), id: userID)
                        return user
                    })
                    completion(.success(users ?? []))
                }
            }
    }
    
//    MARK: - ArtObject Methods
    
    func createArtObject(artObject: ArtObject, completion: @ escaping (Result<(), Error>) -> ()) {
        var fields: [String:Any] = artObject.fieldsDict
        fields["dateCreated"] = Date()
        database.collection(FirestoreCollections.ArtObject.rawValue).document(artObject.artID).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            
            completion(.success(()))
        }
    }
    
    func getAllArtObjects(completion: @escaping (Result<[ArtObject], Error>) -> ()) {
        database.collectionGroup(FirestoreCollections.ArtObject.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let artObjects = snapshot?.documents.compactMap({ (snapshot) -> ArtObject? in
                    let artObjectID = snapshot.documentID
                    let artObject = ArtObject(from: snapshot.data(), id: artObjectID)
                    return artObject
                })
                completion(.success(artObjects ?? []))
            }
        }
    }
    
    func updateArtObjectSoldStatus(newStatus: Bool?, artID: String, completion: @escaping (Result<(), Error>) -> ()) {
//        guard let userID = FirebaseAuthService.manager.currentUser?.uid else {return}
        var updateFields = [String:Any]()
        if let status = newStatus {
            updateFields["soldStatus"] = status
        }
        
        let artObject = database.collection(FirestoreCollections.ArtObject.rawValue).document(artID)
        artObject.updateData(updateFields) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(()))
        }
    }
    
    //MARK: Just Testing For Filtering Posts
    func getPosts(tags: [String], completion: @escaping (Result<[ArtObject], Error>) -> ()) {
        database.collection(FirestoreCollections.ArtObject.rawValue).whereField("tags", isEqualTo: tags).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let posts = snapshot?.documents.compactMap({ (snapshot) -> ArtObject? in
                    let postID = snapshot.documentID
                    let post = ArtObject(from: snapshot.data(), id: postID)
                    return post
                })
                completion(.success(posts ?? []))
            }
        }
        
    }
    
//    MARK: - Favorites Methods
    func createFavoriteArtObject(artObject: ArtObject, completion: @ escaping (Result<(), Error>) -> ()) {
        var fields: [String:Any] = artObject.fieldsDict
        fields["dateCreated"] = Date()
        database.collection(FirestoreCollections.FavoriteArt.rawValue).document(artObject.artID).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            
            completion(.success(()))
        }
    }
//    MARK: TODO - ADD METHOD TO GET FAVORITES FOR THIS USER
    func getAllSavedArtObjects(completion: @escaping (Result<[ArtObject], Error>) -> ()) {
        database.collectionGroup(FirestoreCollections.FavoriteArt.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let artObjects = snapshot?.documents.compactMap({ (snapshot) -> ArtObject? in
                    let artObjectID = snapshot.documentID
                    let artObject = ArtObject(from: snapshot.data(), id: artObjectID)
                    return artObject
                })
                completion(.success(artObjects ?? []))
            }
        }
    }
//    MARK: - TODO: Update to check only for current user.
    
    func removeSavedArtObject(artID: String, completion: @escaping (Result <(), Error>) -> ()) {
        database.collection(FirestoreCollections.FavoriteArt.rawValue).whereField("artID", isEqualTo: artID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    document.reference.delete()
                    completion(.success(()))
                }
            }
        }
    }
}
