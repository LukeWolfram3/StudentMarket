//
//  ProfileViewModel.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/25/25.
//

import Foundation
import PhotosUI
import SwiftUI
/* IMPORTANT NOTE: When data is pushed up to firebase, the entire user and their data is replicated, so if stale data is pushed up to firebase that could be a big problem */


@MainActor
@Observable
final class ProfileViewModel {
    
    private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
        
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }

        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Error in saveProfileImage")
                return
            }
            
            let (storagePath, fileName) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("Storage path:", storagePath)
            
            let downloadURL = try await StorageManager.shared.getUrlForImage(path: storagePath)
            
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: storagePath, url: downloadURL.absoluteString)
            
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func deleteProfileImage() {
        
        guard let user,
              let storagePath = user.profileImageStoragePath else {
            print("No user or profileImageStoragePath to delete.")
            return
        }
        
        Task {
            print("Deleting image at storage path:", storagePath)
            try await StorageManager.shared.deleteImage(path: storagePath)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
            
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            print("Delete complete")
        }
    }
}



//    func saveProfileImage(item: PhotosPickerItem) {
//        guard let user else { return }
//
//        Task {
//            guard let data = try await item.loadTransferable(type: Data.self) else {
//                print("Error in saveProfileImage")
//                return
//            }
//            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
//            print("SUCCESS!")
//            print(path)
//            print(name)
//            let url = try await StorageManager.shared.getUrlForImage(path: path)
//            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: url.absoluteString, url: url.absoluteString)
//        }
//    }


//func deleteProfileImage() {
//    print("Getting the user and the user profile image path")
//    guard let user, let path = user.profileImageStoragePath else { return }
//    
//    print("user and path found")
//
//    Task {
//        print("attempting to delete the image")
//        try await StorageManager.shared.deleteImage(path: path)
//        print("Image deleted, upadting user")
//        try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
//        print("SUCCESS")
//    }
//}
