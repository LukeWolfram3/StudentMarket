//
//  Models.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/17/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isEmailVerified: Bool 
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isEmailVerified = user.isEmailVerified
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            print("Failed to get authenticated user")
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        return AuthDataResultModel(user: user)
    }
    
    @discardableResult
    func checkCurrentUserSignInStatus() throws -> Bool {
        guard Auth.auth().currentUser != nil else {
            print("Failed to get authenticated user")
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        return true
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            print("Unable to get provider")
            throw AuthenticationErrors.unableToGetProvider
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                print(option.rawValue)
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    
    func checkEmailVerificationStatus() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        
        if VerificationCache.isUserVerifiedInCache(uid: user.uid) {
            // User is signed in and their email is verified locally return true
            print("Found user verified email in cache/User Defaults")
            return true
        }
        
        if user.isEmailVerified {
            //User's email is verified but not cached yet
            VerificationCache.setUserVerified(uid: user.uid )
            print("Found user verified email in AuthDataResult model and added to User Defaults/cache")
            return true
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.reload() { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        if user.isEmailVerified {
            VerificationCache.setUserVerified(uid: user.uid)
            print("Found the user's verified email on firebase, adding to this devices User Defaults/cache")
        }
        return user.isEmailVerified
    }
}


//MARK: SIGN IN EMAIL
extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
         return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func reauthenticateUser(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        print("Current user found")
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        print("Credential created: \(credential)")
        
        
        let reauthenticatedUser = try await user.reauthenticate(with: credential)
        print("reauthenticatedUser created: \(reauthenticatedUser)")
        
        print("Comparing current user uuid: \(user.uid) == reauthenticatedUser.user.uuid \(reauthenticatedUser.user.uid)")
        guard user.uid == reauthenticatedUser.user.uid else {
            throw AuthenticationErrors.userInfoNotCurrentUser
        }
        print("Guard statement passed")
    }
        
        
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated")
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        
        try await user.updatePassword(to: password)
    }

    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user found")
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        VerificationCache.deleteUserVerification(uid: user.uid)
        
        try await user.delete()
    }
    
    func sendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationErrors.failedToGetAuthenticatedUser
        }
        do {
            try await user.sendEmailVerification()
        } catch {
            
        }
    }
}



// MARK: SIGN IN SSO

extension AuthenticationManager {

    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}

// MARK: CUSTOM ERRORS
extension AuthenticationManager {
    
    enum AuthenticationErrors: Error {
        case failedToGetAuthenticatedUser
        case unableToGetProvider
        case userInfoNotCurrentUser
        
        var errorDescription: String? {
            switch self {
            case .failedToGetAuthenticatedUser:
                return "Failed to get authenticated user"
            case .unableToGetProvider:
                return "Failed to get provider"
            case .userInfoNotCurrentUser:
                return "The current user's information does not match the information inputted"
            }
        }
    }
}





@Observable final class SignInAndCreateUsers {
    
    var firstName: String = ""
    var displayName = ""
    var email = ""
    var password = ""
    
    enum SignInError: Error {
        case emptyEmail
        case invalidEmail
        case invalidPassword
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No user")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        guard !email.isEmpty else {
            throw SignInError.emptyEmail
        }
        guard !password.isEmpty else {
            throw SignInError.invalidPassword
        }
            try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func resetPassword() async throws {
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
}


