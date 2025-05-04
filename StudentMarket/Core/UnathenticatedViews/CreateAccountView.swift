//
//  CreateAccountView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/14/24.
//

import SwiftUI
import Foundation


// MAKE CUSTOM ERRORS BASED ON THE ERROR LOG FROM FIREBASE

struct CreateAccountView: View {
    
    @Bindable var signInAndCreateUsersViewModel: SignInAndCreateUsers
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedField: Field?
    
    @State private var isTermsOfServiceAgreed = false
    @State private var isTermsOfServiceShown = false
    @State private var isAlertShown = false
    @State private var errorMessage: String? = nil
    @Binding var isEmailVerificationSheetShown: Bool
    @Binding var isVerifyEmailViewShown: Bool

    
    enum Field {
        case firstName
        case displayName
        case email
        case password
    }
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            VStack(alignment: .leading) {
                HStack {
                    xButton
                    header
                }
                
                TextField("", text: $signInAndCreateUsersViewModel.firstName)
                    .textInputAutocapitalization(.never)
                    .modifier(DefaultTextfieldViewModifier(
                        focusedField: $focusedField,
                        currentField: .firstName, 
                        text: $signInAndCreateUsersViewModel.firstName,
                        label: "First name"))
                
                TextField("", text: $signInAndCreateUsersViewModel.displayName)
                    .textInputAutocapitalization(.never)
                    .modifier(DefaultTextfieldViewModifier(
                        focusedField: $focusedField,
                        currentField: .displayName,
                        text: $signInAndCreateUsersViewModel.displayName,
                        label: "Display name"))
                
                TextField("", text: $signInAndCreateUsersViewModel.email)
                    .textInputAutocapitalization(.never)
                    .modifier(DefaultTextfieldViewModifier(
                        focusedField: $focusedField,
                        currentField: .email, 
                        text: $signInAndCreateUsersViewModel.email,
                        label: "Student email"))
                
                SecureField("", text: $signInAndCreateUsersViewModel.password)
                    .textInputAutocapitalization(.never)
                    .modifier(DefaultTextfieldViewModifier(
                        focusedField: $focusedField,
                        currentField: .password, 
                        text: $signInAndCreateUsersViewModel.password,
                        label: "Password"))
                
                Spacer()
                Spacer()
                termsOfService
                Spacer()
                
                ZStack(alignment: .center) {
                    continueButton
                }
                .frame(maxWidth: .infinity)
            }
            
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .sheet(isPresented: $isTermsOfServiceShown, content: {
            TermsOfService()
        })
        .alert(Text(""), isPresented: $isAlertShown, actions: {
            Button {
                isAlertShown.toggle()
            } label: {
                Text("OK")
            }
        }, message: {
            Text(errorMessage ?? "Unable to provide error" )
        })
        .animation(.default, value: focusedField)
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    CreateAccountView(signInAndCreateUsersViewModel: SignInAndCreateUsers(), isEmailVerificationSheetShown: .constant(false), isVerifyEmailViewShown: .constant(false))
}


enum ValidateInput {
    case emptyFirstName
    case emptyDisplayName
    case invalidEmail
    case weakPassword
    case agreeToTermsOfService
    
    var description: String {
        switch self {
        case .emptyFirstName:
            return "First name cannot be empty."
        case .emptyDisplayName:
            return "Display name cannot be empty."
        case .invalidEmail:
            return "Invalid or non student email."
        case .weakPassword:
            return "Password must be at least 6 characters and contain a special character."
        case .agreeToTermsOfService:
            return "Must agree to terms of service"
        }
    }
    
}



extension CreateAccountView {
    
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
    private var header: some View {
        Text("Create account")
            .foregroundStyle(Color("MainColor"))
            .font(.largeTitle)
            .bold()
            .padding(.leading, 15)
            .padding(.top, 25)
            .shadow(color: Color("MainColor"), radius: 15, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 15)
    }
    
    private var continueButton: some View {
        Button {
            if let error = checkAllRequirements() {
                errorMessage = error.description
                isAlertShown = true
                print(error)
            } else {
                Task {
                    do {
                        try await signInAndCreateUsersViewModel.signUp()
                        print("User created")
                        try await AuthenticationManager.shared.sendVerificationEmail()
                        print("Email sent")
                        isVerifyEmailViewShown = true
                        dismiss()
                        return
                    } catch {
                        errorMessage = "Error creating account. Could be an invalid password, network connection, invalid email, etc."
                        isAlertShown = true
                        print(error)
                    }
                }
            }
        } label: {
            Text("Continue")
                .foregroundStyle(checkAllRequirements() == nil ? Color("MainColor") : .white)
                .withDefaultContinueButton(
                    backgroundColor: .black,
                    strokeColor: checkAllRequirements() == nil ? Color("MainColor") : .white,
                    shadowColor: checkAllRequirements() == nil ? Color("MainColor") : .white, width: 200)
        }
        .withPressableStyle()
    }
    
    private var termsOfService: some View {
        HStack {
            Image(systemName: isTermsOfServiceAgreed ? "checkmark.square.fill" : "square")
                .foregroundStyle(isTermsOfServiceAgreed ? Color("MainColor") : .white)
                .font(.largeTitle)
                .onTapGesture {
                    withAnimation {
                        isTermsOfServiceAgreed.toggle()
                    }
                }
            Text("Terms of service")
                .underline()
                .foregroundStyle(.white)
                .font(.title2).bold()
                .onTapGesture {
                    isTermsOfServiceShown.toggle()
                }
        }
        .padding(.horizontal, 15)
    }
    
    private func checkAllRequirements() -> ValidateInput? {
        guard !signInAndCreateUsersViewModel.firstName.isEmpty else {
            return .emptyFirstName
        }
        guard !signInAndCreateUsersViewModel.displayName.isEmpty else {
            return .emptyDisplayName
        }
        guard isValidUNCEmail(signInAndCreateUsersViewModel.email) else {
            return .invalidEmail
        }
        guard checkPasswordValidity(password: signInAndCreateUsersViewModel.password) else {
            return .weakPassword
        }
        guard isTermsOfServiceAgreed else {
            return .agreeToTermsOfService
        }
        return nil
    }
    
    func isValidUNCEmail(_ email: String) -> Bool {
        let uncEmailRegEx = "[A-Z0-9a-z._%+-]+@unc\\.edu$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uncEmailRegEx)
        return predicate.evaluate(with: email)
    }
    
    private func checkPasswordValidity(password: String) -> Bool {
        let specialCharacters = "!@#$%^&*_-()"
        let containsSpecial = password.contains { specialCharacters.contains($0)}
        return password.count > 5 && containsSpecial
        }
}


struct DefaultTextfieldViewModifier: ViewModifier {
    
    var focusedField: FocusState<CreateAccountView.Field?>.Binding
    
    let currentField: CreateAccountView.Field
    @Binding var text: String
    let label: String
    let fillColor: Color = Color.black
    let focusedColor: Color = Color("MainColor")
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15)
                .stroke(currentStrokeColor, lineWidth: 5)
                .fill(fillColor)
                .frame(height: 55)
            
            content
                .focused(focusedField, equals: currentField)
                .foregroundStyle(.white)
                .padding()
            
            Text(label)
                .font(.headline)
                .background(fillColor)
                .foregroundStyle(currentForegroundStyle)
                .padding()
                .offset(y: isFieldActive ? -27 : 0)
        }
        .onTapGesture {
            focusedField.wrappedValue = currentField
        }
        .padding(10)
    }
    
    private var isFieldActive: Bool {
        (focusedField.wrappedValue == currentField) || !text.isEmpty
    }
    
    private var isPasswordValid: Bool {
        guard label == "Password" else { return false }
        return checkPasswordValidity(password: text)
    }

    private var currentStrokeColor: Color {
        if label == "Password" {
            return ((isFieldActive && isPasswordValid) ? focusedColor : .white)
        } else if label == "Student email" {
            return isValidUNCEmail(text) ? focusedColor : .white
        } else {
            return isFieldActive ? focusedColor : .white
        }
    }
    
    private var currentForegroundStyle: Color {
        if label == "Password" {
            return ((isFieldActive && isPasswordValid) ? focusedColor : .white)
        } else if label == "Student email" {
            return isValidUNCEmail(text) ? focusedColor : .white
        } else {
            return isFieldActive ? focusedColor : .white
        }
    }
    
    
    private func checkPasswordValidity(password: String) -> Bool {
        let specialCharacters = "!@#$%^&*_-()"
        let containsSpecial = password.contains { specialCharacters.contains($0)}
        return password.count > 6 && containsSpecial
        }
    
    func isValidUNCEmail(_ email: String) -> Bool {
        let uncEmailRegEx = "[A-Z0-9a-z._%+-]+@unc\\.edu$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uncEmailRegEx)
        return predicate.evaluate(with: email)
    }
}
