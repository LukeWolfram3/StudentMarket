//
//  RootView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/31/24.
//

import SwiftUI

/*If we get an error: No exact matches in reference to static method 'buildExpression' it means there is an error with the way one of the views below is being called, likely the parameters*/

// Instead of using a case for the email is not verified, we are going to use the Bool instead to trigger a sheet from the sign in View


@MainActor
struct RootView: View {
    @State private var authenticationViewModel = AuthenticationViewModel()
    @State private var signInAndCreateUsersViewModel: SignInAndCreateUsers = SignInAndCreateUsers()
    
    
    var body: some View {
        withObservationTracking {
            Group {
                switch authenticationViewModel.appAuthState {
                case .loading:
                    MyProgressView()
                case .unauthenticated:
                    SignInView(
                        signInAndCreateUsersViewModel: signInAndCreateUsersViewModel,
                        authenticationViewModel: authenticationViewModel)
                case .authenticated:
                    NavigationStack {
//                        ProfileView(
//                            authenticationViewModel: authenticationViewModel,
//                            signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
//                        MainView(
//                            authenticationViewModel: authenticationViewModel,
//                            signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
                        TabbarView(authenticationViewModel: authenticationViewModel, signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
                    }
                }
            }
            } onChange: { }
        
}
}


#Preview {
    RootView()
}


//        self.isSignInViewShown = authuser == nil


//        .onAppear {
//            print("GETTING AUTH PROVIDERS")
//            authenticationViewModel.loadAuthProviders()
//        }


//extension RootView {
//
//    private func checkUserStatus() async  {
//        do {
//            let user = try AuthenticationManager.shared.getAuthenticatedUser()
//            // If this can't find a user it'll throw an error which will trigger our catch statment
//
//            if VerificationCache.isUserVerifiedInCache(uid: user.uid) {
//                // User is signed in and their email is verified locally
//                isLoading = false
//                return
//            }
//
//            if user.isEmailVerified {
//                //User's email is verified but not cached yet
//                VerificationCache.setUserVerified(uid: user.uid )
//                isLoading = false
//                return
//            }
//
//            //Email is not locally verified, so checking firebase
//            let isVerifiedNow = try await AuthenticationManager.shared.checkEmailVerificationStatus()
//
//            if isVerifiedNow {
//                VerificationCache.setUserVerified(uid: user.uid)
//            } else {
//                showVerifyEmailView = true
//            }
//            isLoading = false
//
//        } catch {
//            print("No current user, or error: \(error)")
//            self.isSignInViewShown = true
//            isLoading = false
//        }
//    }
//}
