//
//  AuthenticationViewModel.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/24/24.
//

import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
@Observable
final class AuthenticationViewModel {
    
    var appAuthState: AppAuthState = .loading
    var isEmailVerified: Bool = false
    var authProviders: [AuthProviderOption] = []
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
       authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            Task {
                await self?.updateAuthState(user: user)
            }
        }
        
        Task {
            let user = Auth.auth().currentUser
            await self.updateAuthState(user: user)
        }
    }
    
    private func updateAuthState(user: User?) async {
        guard user != nil else {
            self.appAuthState = .unauthenticated
            return
        }
        
            do {
                let isVerified = try await AuthenticationManager.shared.checkEmailVerificationStatus()
                if isVerified {
                    self.appAuthState = .authenticated
                    print("GETTING AUTH PROVIDERS FROM updateAuthState")
                    loadAuthProviders()
                } else {
                    print("The user is signed in but email is not verified")
                    isEmailVerified = false
                    self.appAuthState = .unauthenticated
                    
                }
            } catch {
                print("Error checking email verification: \(error)")
                isEmailVerified = false
                self.appAuthState = .unauthenticated
            }
        }    

    
    
    func loadAuthProviders() {
        if let provider = try? AuthenticationManager.shared.getProviders() {
            authProviders = provider
        }
    }
    
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            withAnimation {
                self.appAuthState = .unauthenticated
            }
            print("User signed out")
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await AuthenticationManager.shared.delete()
            
            withAnimation {
                self.appAuthState = .unauthenticated
            }
            print("Account deleted")
        } catch {
            print("Error deleting account \(error)")
        }
    }

}



/*
 func signInApple() async throws {
 let helper = SignInAppleHelper()
 let tokens = try await helper.startSignInWithAppleFlow()
 let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
 let user = DBUser(auth: authDataResult)
 try await UserManager.shared.createNewUser(user: user)
 }
 */
