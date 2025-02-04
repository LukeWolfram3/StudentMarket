//
//  VerificationCache.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/31/24.
//

import Foundation

struct VerificationCache {
    private static let verifiedUsersKey = "verifiedUsers"
    
    // Marks the user's UID as verified
    static func setUserVerified(uid: String) {
        var verifiedUsers = getVerifiedUsers()
        verifiedUsers.insert(uid) // store the user’s UID in a local Set
        UserDefaults.standard.set(Array(verifiedUsers), forKey: verifiedUsersKey)
    }
    
    /// Returns true if we've previously marked this user as verified
    static func isUserVerifiedInCache(uid: String) -> Bool {
        let verifiedUsers = getVerifiedUsers()
        return verifiedUsers.contains(uid)
    }
    
    /// Helper: read from UserDefaults, interpret as [String], then make it a Set
    private static func getVerifiedUsers() -> Set<String> {
        let usersArray = UserDefaults.standard.stringArray(forKey: verifiedUsersKey) ?? []
        return Set(usersArray)
    }
    
    static func deleteUserVerification(uid: String) {
        var verifiedUsers = getVerifiedUsers()
        print("Currnet verifiedUsers: \(verifiedUsers)")

        verifiedUsers.remove(uid)
        print("User removed from cache: \(uid). Current verifiedUsers: \(verifiedUsers)")
        
        // Save the updated set back to UserDefaults
        UserDefaults.standard.set(Array(verifiedUsers), forKey: verifiedUsersKey)
    }
    
    static func clearAllVerifiedUsers() {
        UserDefaults.standard.removeObject(forKey: verifiedUsersKey)
        print("All verified users have been cleared from the cache")
        print(verifiedUsersKey)
    }
}
