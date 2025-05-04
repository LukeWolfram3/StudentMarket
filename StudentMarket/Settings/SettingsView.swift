//
//  SettingsView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/18/24.
//

import SwiftUI

@MainActor
struct SettingsView: View {
    
    @Bindable var authenticationViewModel: AuthenticationViewModel
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers

    
    @State private var isResignInAlertShown: Bool = false
    @State private var isWarningAlertShown: Bool = false
    @State private var isFailedToDeleteAlertShown: Bool = false
    

    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    
    
    var body: some View {
        ZStack {
            List {
                Button("Log out") {
                    signOut()
                }
                
                Button(role: .destructive) {
                    isWarningAlertShown.toggle()
                } label: {
                    Text("Delete account")
                }
                
                if authenticationViewModel.authProviders.contains(.email) {
                    Text("Email")
                    //Put in the email section
                }

            }
        }
        .warningAlert(
            isPresented: $isWarningAlertShown,
            onConfirm: {
            isWarningAlertShown = false
            deleteUserAccount()
        })
        .reSignInAlert(
            isPresented: $isResignInAlertShown,
            emailInput: $emailInput,
            passwordInput: $passwordInput) /* on confirm*/ {
                emailInput = ""
                passwordInput = ""
                isResignInAlertShown = false
            } onDelete: {
                Task {
                    do {
                        try await deleteUserAccountEmailAndPassword()
                        emailInput = ""
                        passwordInput = ""
                        signInAndCreateUsersViewModel.email = ""
                        signInAndCreateUsersViewModel.password = ""
                    } catch {
                        print("Error with deleteUserAccountEmailAndPassword() function")
                        emailInput = ""
                        passwordInput = ""
                        isResignInAlertShown = false
                        isFailedToDeleteAlertShown = true
                    }
                }
            }
            .failedToDeleteAlert(isPresented: $isFailedToDeleteAlertShown)
    }
}

//MARK: Alert ViewBuilders
extension View {
    
    @ViewBuilder
    func warningAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.alert(
            Text("Account deletion is permanent, are you sure you want to continue?"),
            isPresented: isPresented
        ) {
            Button("Cancel", role: .cancel) {
                isPresented.wrappedValue = false
            }
            Button("Sign in") {
                isPresented.wrappedValue = false
                onConfirm()
            }
        } message: {
            Text("Resign in is required for account deletion")
        }
    }

    @ViewBuilder
    func reSignInAlert(
        isPresented: Binding<Bool>,
        emailInput: Binding<String>,
        passwordInput: Binding<String>,
        onCancel: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        self.alert(Text("Resign in needed"),
                   isPresented: isPresented) {
            
            
            TextField("Email...", text: emailInput)
                .textInputAutocapitalization(.never)
            
            SecureField("Password...", text: passwordInput)
                .textInputAutocapitalization(.never)
            
            Button("Cancel", role: .cancel) {
                onCancel()
            }
            
            Button("Delete", role: .destructive) {
                onDelete()
            }

        } message: {
            Text("Account deletion is permanent, are you sure you want to continue?")
        }

    }
    
    
    @ViewBuilder
    func failedToDeleteAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        self.alert(
            Text("Failed to delete account"),
            isPresented: isPresented
        ) {
            Button("OK") {
                isPresented.wrappedValue = false
            }
        } message: {
            Text("Resign in failed")
        }
    }

}


//MARK: FUNCTIONS
extension SettingsView {
    
    private func deleteUserAccount() {
        authenticationViewModel.loadAuthProviders()
        print("authenticationViewModel.authProviders: \(authenticationViewModel.authProviders)")
        
        if authenticationViewModel.authProviders.contains(.email) {
            isResignInAlertShown.toggle()
        } else {
            print("Could not find the provider")
        }
        
    }
    
    private func deleteUserAccountEmailAndPassword() async throws {

        try await AuthenticationManager.shared.reauthenticateUser(email: emailInput, password: passwordInput)
        print("Reauthentication failed")
        
        try await authenticationViewModel.deleteAccount()
        print("User sucessfully deleted")
    }
    
    
    private func signOut() {
//        Task {
//            do {
                authenticationViewModel.signOut()
                signInAndCreateUsersViewModel.firstName = ""
                signInAndCreateUsersViewModel.displayName = ""
                signInAndCreateUsersViewModel.email = ""
                signInAndCreateUsersViewModel.password = ""
//                isSignInViewShown = true
                
//            } catch {
//                print(error)
//            }
        }
//    }
}



#Preview {
    NavigationStack {
        SettingsView(authenticationViewModel: AuthenticationViewModel(), signInAndCreateUsersViewModel: SignInAndCreateUsers())
    }
}


enum DeletingAccountErrors: Error {
    case invalidUser
}

enum ActiveAlert {
    case warning, failedDelete, reSignIn
}







