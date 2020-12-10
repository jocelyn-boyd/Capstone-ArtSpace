//
//  FirebaseStorageService.swift
//  ArtSpaceDos
//
//  Created by Levi Davis on 2/3/20.
//  Copyright © 2020 Jocelyn Boyd. All rights reserved.
//

import Foundation
import FirebaseStorage

enum pictureUploadType: String {
    case artPiece = "artPiece"
    case profilePicture = "profilePicture"
}

class FirebaseStorageService {

    static let manager = FirebaseStorageService()
    
    private let storage: Storage!
    private let storageReference: StorageReference
    private let imagesFolderReference: StorageReference
    
    private init() {
        storage = Storage.storage()
        storageReference = storage.reference()
        imagesFolderReference = storageReference.child(pictureUploadType.artPiece.rawValue)
    }
    
    func storeImage(pictureType: pictureUploadType,image: Data, completion: @escaping (Result<URL, Error>) -> ()) {
        
        guard let user = FirebaseAuthService.manager.currentUser else {return}
        let metaData = StorageMetadata()
        let userID = user.uid
        metaData.contentType = "image/jpeg"
        let uuid = UUID()
        var imageLocation = storageReference
        switch pictureType {
        case .artPiece:
            imageLocation = storageReference.child("\(pictureType.rawValue)").child(uuid.description)
            
        case .profilePicture:
            imageLocation = storageReference.child("\(pictureType.rawValue)").child(userID)
        }
//        let imageLocation = imagesFolderReference.child(uuid.description)
        imageLocation.putData(image, metadata: metaData) { (responseMetaData, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                imageLocation.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        imageLocation.downloadURL { (url, error) in
                            guard error == nil, let url = url else {completion(.failure(error!)); return}
                            completion(.success(url))
                        }
                    }
                }
            }
        }
    }
}
