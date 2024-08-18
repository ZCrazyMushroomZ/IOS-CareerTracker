//
//  ItemRepository.swift
//  MovieListApp
//
//  Created by Yi Ling on 4/19/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseStorage
import CoreTransferable

@MainActor public class ProfileRepository: ObservableObject {
    
    @Published var profile = Profile()
    @Published var imageReady = false
    
    private let db = Firestore.firestore()
    
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        DispatchQueue.main.async{
            self.subscribe()
        }
    }
    
    deinit {
        DispatchQueue.main.async {
            self.unsubscribe()
        }
    }
    
    func subscribe() {           // This function downloads user's data from firebase server
        if listenerRegistration == nil {
            
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            let query = db.collection("profiles")
            listenerRegistration = query
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    DispatchQueue.main.async{
                        guard let documents = querySnapshot?.documents else {
                            print("No documents")
                            return
                        }
                        print("Mapping \(documents.count) documents")
                        for document in documents{
                            if (document.documentID == userId){
                                do{
                                    try self?.profile = document.data(as: Profile.self)
                                } catch {
                                    print("Profile not found")
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func unsubscribe() {   // This function resets user's data
        DispatchQueue.main.async{
            if self.listenerRegistration != nil {
                self.listenerRegistration?.remove()
                self.listenerRegistration = nil
            }
            self.profile = Profile()
            self.imageState = .empty
            self.imageSelection = nil
        }
    }
    
    func updateProfile() {           // This function posts the changes to the server
        DispatchQueue.main.async{
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            do {
                let documentRef = self.db.collection("profiles").document(userId)
                try documentRef.setData(from: self.profile)
            }
            catch {
                print("Unable to update item to firebase: \(error.localizedDescription)")
            }
        }
    }
    
    enum ImageState {
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImage: Transferable {
        let image: UIImage
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                return ProfileImage(image: uiImage)
           }
        }
    }
    
    @Published private(set) var imageState: ImageState = .empty
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
    func uploadProfileImage(image: UIImage) {          // This function uploads the image (type UIImage) to the server
        DispatchQueue.main.async{
            guard var imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let profileImagesRef = storageRef.child("profile_images")
            let userId = Auth.auth().currentUser?.uid ?? "unknown_user"
            let imageRef = profileImagesRef.child("\(userId).jpg")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: metaData) { metadata, error in
                guard error == nil else {
                    print("Error uploading image: \(error!.localizedDescription)")
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let url = url {
                        print("Image uploaded successfully. URL: \(url)")
                        self.profile.picUrl = url.absoluteString
                        self.updateProfile()
                    } else {
                        print("Failed to get download URL for the uploaded image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download image:", error.localizedDescription)
                completion(nil)
                return
            }
            guard let imageData = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let uiImage = UIImage(data: imageData) {
                completion(uiImage)
                print("Image download successful!")
            } else {
                print("Failed to create UIImage from data")
                completion(nil) 
            }
        }
        task.resume()
    }

    
    func setOnlineImage(){
        if (self.profile.picUrl != ""){
            let url = URL(string: self.profile.picUrl)
            DispatchQueue.main.async{
                self.downloadImage(from: url!) { image in
                    if let image = image {
                        self.imageState = .success(image)
                        self.imageReady = true
                        print("Downloaded image:", image)
                    } else {
                        print("Failed to download image")
                    }
                }
            }
        }
    }
}
