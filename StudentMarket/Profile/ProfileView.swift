//
//  ProfileView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/5/25.
//

import SwiftUI
import PhotosUI


@MainActor
struct ProfileView: View {
    
    @State private var viewModel: ProfileViewModel = ProfileViewModel()
    @Bindable var authenticationViewModel: AuthenticationViewModel
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers
    @State private var url: URL? = nil

    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { string in
                            Button(string) {
                                if preferenceIsSelected(text: string) {
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    viewModel.addUserPreference(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: string) ? .green : .red)
                        }
                    }
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select a photo")
                    }
                
                if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                    
                }
                
                if user.profileImageStoragePath != nil {
                    Button("Delete image") {
                        viewModel.deleteProfileImage()
                    }
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .onChange(of: selectedItem, { oldValue, newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView(
                        authenticationViewModel: authenticationViewModel, signInAndCreateUsersViewModel: signInAndCreateUsersViewModel)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }

    }
}

#Preview {
    ProfileView(
        authenticationViewModel: AuthenticationViewModel(), signInAndCreateUsersViewModel: SignInAndCreateUsers())
}
