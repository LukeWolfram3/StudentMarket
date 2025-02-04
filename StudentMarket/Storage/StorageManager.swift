//
//  StorageManager.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/25/25.
//

import Foundation
import FirebaseStorage
import UIKit
// FIREBASE EXTENSIONS: RESIZE IMAGES

final class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    func getData(userId: String, path: String) async throws -> Data {
//        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badURL)
        }
        
        return image
    }
    
    //Meta data is important to include to prevent against data corruption when you are uploading
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        // image.pngData() for images that have the transparent background
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, userId: userId)
    }
    
    func deleteImage(path: String) async throws {
        try await getPathForImage(path: path).delete()
    }
}
