//
//  MainView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/16/24.
//

import SwiftUI

@MainActor
struct MainView: View {
    
    @Bindable var authenticationViewModel: AuthenticationViewModel
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers


    
    var body: some View {
        NavigationStack {
            ZStack {
                ProductsView()
//                ProfileView(
//                    authenticationViewModel: authenticationViewModel,
//                    signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
//                    NavigationLink("Settings") {
//                        SettingsView(
//                            authenticationViewModel: authenticationViewModel,
//                            signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
//                    }
            }
        }
    }
}

#Preview {
    MainView(authenticationViewModel: AuthenticationViewModel(), signInAndCreateUsersViewModel: SignInAndCreateUsers())
}


//extension MainView {
    
//    private func getUserProvider() {
//        Task {
//            do {
//                _ = try AuthenticationManager.shared.getAuthenticatedUser()
//                authenticationViewModel.loadAuthProviders()
//                print("viewModel.authProviders: \(authenticationViewModel.authProviders.description)")
//            } catch {
//                print("User is not authenticated or unable to get providers: \(error)")
//            }
//        }
//    }
//}
