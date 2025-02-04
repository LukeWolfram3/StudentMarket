//
//  VerifyEmailView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/29/24.
//

import SwiftUI



@MainActor
struct VerifyEmailView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers
    @Bindable var authenticationViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    
    //Utility alert used for mutliple things
    @State private var isUtilityAlertShown: Bool = false
    @State private var utilityAlertText: String = ""
    
    @State private var isCancelAccountAlertShown: Bool = false
    @State private var isEditEmailAlertShown: Bool = false
    
    @State private var displayEmail: String = ""
    @State private var editedEmail: String = ""
    
    @State private var verificationTimer: Timer?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.black).ignoresSafeArea()
            
            VStack(spacing: 15) {
                HStack {
                    xButton
                    header
                }
                description
                
                Spacer()
                                
                displayCurrentEmail
                resendEmailButton
                editEmail
                checkVerificationButton
                
                Spacer()
                
            }
            .alert(utilityAlertText, isPresented: $isUtilityAlertShown, actions: {
                Button {
                    isUtilityAlertShown = false
                } label: {
                    Text("OK")
                }
            }, message: {
                
            })
            .editEmailAlert(
                isPresented: $isEditEmailAlertShown,
                emailDisplayed: displayEmail,
                emailEdited: $editedEmail,
                onCancel: {
                    displayEmail = signInAndCreateUsersViewModel.email
                    editedEmail = signInAndCreateUsersViewModel.email
                },
                onConfirm: {
                    guard isValidUNCEmail(editedEmail) else {
                        utilityAlertText = "Email must be valid"
                        isUtilityAlertShown = true
                        isEditEmailAlertShown = false
                        return
                    }
                    signInAndCreateUsersViewModel.email = editedEmail
                    displayEmail = editedEmail
                    Task {
                        do {
                            try await AuthenticationManager.shared.sendVerificationEmail()
                            print("Email sent to \(signInAndCreateUsersViewModel.email)")
                        } catch {
                            print("Error \(error)")
                            utilityAlertText = "Error sending email to \(signInAndCreateUsersViewModel.email)"
                            isUtilityAlertShown = true
                        }
                    }
                })
            .padding(20)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    let verified = try await AuthenticationManager.shared.checkEmailVerificationStatus()
                    if verified {
                        authenticationViewModel.appAuthState = .authenticated
                    }
                }
            }
        }
        .onAppear {
            displayEmail = signInAndCreateUsersViewModel.email
            editedEmail = signInAndCreateUsersViewModel.email
            
            verificationTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
                Task {
                    await checkVerificationStatus()
                }
            })
        }
        .onDisappear {
            verificationTimer?.invalidate()
            verificationTimer = nil
        }
    }
}

#Preview {
    VerifyEmailView(signInAndCreateUsersViewModel: SignInAndCreateUsers(), authenticationViewModel: AuthenticationViewModel())
}

extension View {
    
    @ViewBuilder
    func editEmailAlert(
        isPresented: Binding<Bool>,
        emailDisplayed: String,
        emailEdited: Binding<String>,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.alert(
            Text("Edit email"),
            isPresented: isPresented) {
                
                TextField("\(emailEdited)", text: emailEdited)
                
                Button("Cancel") {
                    onCancel()
                }
                
                Button("Resend") {
                    onConfirm()
                }
            } message: {
                Text(emailDisplayed)
            }

    }
}


extension VerifyEmailView {
    
    private var header: some View {
        Text("Verify your email")
            .foregroundStyle(Color("MainColor"))
            .font(.largeTitle)
            .bold()
            .padding(.leading, 15)
            .padding(.top, 25)
            .shadow(color: Color("MainColor"), radius: 15, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 15)

    }
    
    private var displayCurrentEmail: some View {
//        Text("\(currentEmail)")
        Text(verbatim: "Lwolfram@unc.edu")
            .foregroundStyle(.black)
            .padding()
            .font(.title2).bold()
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(15)
    }
    
    private var description: some View {
        Text("An email has been sent. Check outlook and follow the instructions to verify your account. Email may take several minutes.")
            .padding()
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(15)

    }
    
    private var resendEmailButton: some View {
        Button {
            Task {
                do {
                    try await AuthenticationManager.shared.sendVerificationEmail()
                    print("Email supposed to be sent")
                    utilityAlertText = "Email successfully sent"
                    isUtilityAlertShown = true
                } catch {
                    print("Failed to send verification email: \(error)")
                    utilityAlertText = "Failed to send the email"
                    isUtilityAlertShown = true
                }
            }
        } label: {
            Text("Resend email")
                .foregroundStyle(Color("MainColor"))
                .withDefaultContinueButton(
                    backgroundColor: Color(.black),
                    strokeColor: Color("MainColor"),
                    shadowColor: Color(.black))
        }
        .withPressableStyle()

    }
    
    private var editEmail: some View {
        Button {
            isEditEmailAlertShown = true
        } label: {
            Text("Edit email")
                .foregroundStyle(Color("MainColor"))
                .withDefaultContinueButton(
                    backgroundColor: .black,
                    strokeColor: Color("MainColor"),
                    shadowColor: .black)
        }
        .withPressableStyle()
    }
    
    private var checkVerificationButton: some View {
        Button {
            Task {
                let verified = try await AuthenticationManager.shared.checkEmailVerificationStatus()
                if verified {
                    authenticationViewModel.appAuthState = .authenticated
                } else if verified == false {
                    utilityAlertText = "Email not yet verified"
                    isUtilityAlertShown = true
                }
            }
        } label: {
            Text("Check verification status")
                .foregroundStyle(Color("MainColor"))
                .foregroundStyle(Color("MainColor"))
                .withDefaultContinueButton(
                    backgroundColor: .black,
                    strokeColor: Color("MainColor"),
                    shadowColor: .black)
        }
        .withPressableStyle()
    }
    
    private var xButton: some View {
        Image(systemName: "xmark")
            .font(.largeTitle)
            .bold()
            .padding(.leading, 10)
            .padding(.top, 25)
            .foregroundStyle(Color("MainColor"))
            .onTapGesture {
                dismiss()
            }
        }
    
    private func checkVerificationStatus() async {
        do {
            let verified = try await AuthenticationManager.shared.checkEmailVerificationStatus()
            if verified {
                // Verified
                authenticationViewModel.appAuthState = .authenticated
                // Optionally stop checking once verified
                verificationTimer?.invalidate()
                verificationTimer = nil
            }
        } catch {
            print("Error checking verification status: \(error)")
        }
    }

    
    func isValidUNCEmail(_ email: String) -> Bool {
        let uncEmailRegEx = "[A-Z0-9a-z._%+-]+@unc\\.edu$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uncEmailRegEx)
        return predicate.evaluate(with: email)
    }
}
