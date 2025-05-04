//
//  ContentView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/11/24.
//

import SwiftUI

/*
Change this so that the signInAndCreateUsersViewModel does not bind to the input fields and instead when the user actually hits the sign in button then set those values to the signInAndCreateUsersViewModel values
 */

@MainActor
struct SignInView: View {
    
    
    
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers
    @Bindable var authenticationViewModel: AuthenticationViewModel
    
    @State private var text: String = ""
    @State private var isPasswordShown: Bool = false
    @State private var isCreateAccountSheetShown: Bool = false
    @State private var isResetPasswordSheetShown: Bool = false
    @State private var isVerifyEmailViewShown: Bool = false
    @State private var isAlertShown: Bool = false
    
    @State private var isLoading = false
    
    
    var body: some View {
        ZStack {
            Color("MainColor").ignoresSafeArea()
            VStack {
                Spacer()
                    Image(systemName: "graduationcap.fill").font(.system(size: 60))
                    Text("Student Market").font(.title).bold()
                    
                    signInWithEmail
                    signInWithPassword
                    signInButton

                
                Spacer()
                
                createAccount
                resetPassword

            }
            .sheet(isPresented: $isCreateAccountSheetShown, content: {
                CreateAccountView(signInAndCreateUsersViewModel: signInAndCreateUsersViewModel,
                                  isEmailVerificationSheetShown: $isVerifyEmailViewShown, isVerifyEmailViewShown: $isVerifyEmailViewShown)
            })
            .sheet(isPresented: $isResetPasswordSheetShown, content: {
                ResetPasswordView(signInAndCreateUsersViewModel: signInAndCreateUsersViewModel, 
                                  isResetPasswordSheetShown: $isResetPasswordSheetShown)
            })
            .sheet(isPresented: $isVerifyEmailViewShown, content: {
                VerifyEmailView(signInAndCreateUsersViewModel: signInAndCreateUsersViewModel, authenticationViewModel: authenticationViewModel)
            })
            .padding()
            
            if isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Signing in...")
                    .padding(30)
                    .background(.white)
                    .cornerRadius(12)
            }
        }

        .onAppear {
            do {
                try AuthenticationManager.shared.checkCurrentUserSignInStatus()
                if authenticationViewModel.isEmailVerified == false {
                    isVerifyEmailViewShown = true
                }
            } catch {
                print("user is not signed in")
            }
            // IF THE USER IS SIGNED IN BUT EMAIL NOT VERIFIED, SHOW SHEET
        }

        .alert(Text("Invalid credentials"), isPresented: $isAlertShown, actions: {
            Button {
                isAlertShown.toggle()
            } label: {
                Text("OK")
            }
        }, message: {
            Text("")
        })
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    SignInView(signInAndCreateUsersViewModel: SignInAndCreateUsers(), authenticationViewModel: AuthenticationViewModel())
}


//MARK: VAR
extension SignInView {
    
    private var createAccount: some View {
        Text("Create account")
            .font(.headline)
            .padding(.top, 30)
            .onTapGesture {
                isCreateAccountSheetShown = true
            }
    }
    
    private var resetPassword: some View {
        Text("Reset Password")
            .font(.headline)
            .padding(.top, 5)
            .onTapGesture {
                isResetPasswordSheetShown = true
            }
    }
    
    private var signInWithEmail: some View {
        TextField("Email...", text: $signInAndCreateUsersViewModel.email)
            .padding()
            .frame(width: 300, height: 55)
            .background(Color.white)
            .cornerRadius(15)
            .textInputAutocapitalization(.never)
    }
    
    private var signInWithPassword: some View {
        
        HStack {
            if !isPasswordShown {
                SecureField("Password...", text: $signInAndCreateUsersViewModel.password)
            } else {
                TextField("Password...", text: $signInAndCreateUsersViewModel.password)
            }
            Image(systemName: "eye.fill")
                .onTapGesture {
                    isPasswordShown.toggle()
                }
        }
        .padding()
        .frame(width: 300, height: 55)
        .background(Color.white)
        .cornerRadius(15)
        .textInputAutocapitalization(.never)
    }
    
    private var signInButton: some View {
        Button {
            isLoading = true
            Task {
                do {
                    try await signInAndCreateUsersViewModel.signIn()
                    if authenticationViewModel.isEmailVerified {
                        authenticationViewModel.appAuthState = .authenticated
                    } else {
                        isVerifyEmailViewShown = true
                    }
                } catch {
                    isAlertShown.toggle()
                    print(error)
                }
                isLoading = false
            }
        } label: {
            Text("Sign in")
                .font(.title2).bold()
                .foregroundStyle(.white)
                .frame(width: 300, height: 55)
                .background(Color.black)
                .cornerRadius(15)
        }
        .withPressableStyle()
    }
}


