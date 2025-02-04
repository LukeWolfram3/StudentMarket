//
//  TabbarView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/23/25.
//

import SwiftUI

struct TabbarView: View {
    
    @Bindable var authenticationViewModel: AuthenticationViewModel
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers

    
    var body: some View {
        TabView {
            NavigationStack {
                ProductsView()
            }
                .tabItem {
                    Image(systemName: "cart")
                    Text("Products")
                }
            
            NavigationStack {
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            
            NavigationStack {
                ProfileView(authenticationViewModel: authenticationViewModel, signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
            }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Settings")
                    }
            

        }
    }
}

#Preview {
    TabbarView(authenticationViewModel: AuthenticationViewModel(), signInAndCreateUsersViewModel: SignInAndCreateUsers())
}
