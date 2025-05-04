//
//  ResetPasswordView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/19/24.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers
    
    @Binding var isResetPasswordSheetShown: Bool
    @State private var isSendButtonPressed: Bool = false
    @State private var isAlertShown: Bool = false
    @State private var alertMessage: String = ""
    @State private var isResetEmailSent: Bool = false

    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                header
                Spacer()
                emailTextField
                sendEmailButton
                Spacer()
                Spacer()
                
            }
        }
        .onChange(of: isAlertShown) { oldValue, newValue in
            if !isAlertShown && isResetEmailSent {
                isResetPasswordSheetShown = false
            }
        }
        .onAppear {
            isResetEmailSent = false
        }
        .alert(alertMessage, isPresented: $isAlertShown, actions: {
            Button {
                isAlertShown.toggle()
            } label: {
                Text("OK")
            }
        }, message: {
            Text("")
        })
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

#Preview {
    ResetPasswordView(signInAndCreateUsersViewModel: SignInAndCreateUsers(), isResetPasswordSheetShown: .constant(false))
}

extension ResetPasswordView {
    
    private var header: some View {
        Text("Reset password")
            .font(.title).bold()
            .foregroundStyle(Color("MainColor"))
            .shadow(color: Color("MainColor"), radius: 7, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 20)
            .padding(.top, 30)
    }
    
    private var emailTextField: some View {
        VStack {
            Text("Enter your email")
                .foregroundStyle(Color("MainColor"))
                .font(.title2).bold()
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("MainColor"), lineWidth: 4)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                HStack {
                    TextField("", text: $signInAndCreateUsersViewModel.email)
                        .foregroundStyle(Color("MainColor"))
                        .font(.headline)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color("MainColor"))
                        .opacity(isValidUNCEmail(signInAndCreateUsersViewModel.email) ? 1 : 0)
                        .padding(.trailing, 10)
                    
                }
            }
            .padding(.horizontal)
        }
    }
        
        private var sendEmailButton: some View {
            Button {
                if isValidUNCEmail(signInAndCreateUsersViewModel.email) {
                    Task {
                        do {
                            try await signInAndCreateUsersViewModel.resetPassword()
                            print("success!")
                            alertMessage = "Email sent! Check outlook"
                            isAlertShown.toggle()
                            isResetEmailSent = true
                            
                        } catch {
                            print(error)
                            alertMessage = "Unable to send email"
                            isAlertShown.toggle()
                        }
                    }
                } else {
                    alertMessage = "Invalid or non student email"
                    isAlertShown.toggle()
                }
                
            } label: {
                Text("Send email")
                    .foregroundStyle(.black)
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.white)
                    .cornerRadius(15)
                    .padding()
            }
            .withPressableStyle()
        }
    
    
    func isValidUNCEmail(_ email: String) -> Bool {
        let uncEmailRegEx = "[A-Z0-9a-z._%+-]+@unc\\.edu$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uncEmailRegEx)
        return predicate.evaluate(with: email)
    }
}
