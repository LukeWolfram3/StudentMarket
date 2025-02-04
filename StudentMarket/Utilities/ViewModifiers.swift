//
//  ButtonStyles.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/16/24.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
}

extension View {
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}


struct ButtonStyles: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Continue")
                .foregroundStyle(Color("MainColor"))
                .withDefaultContinueButton(
                    backgroundColor: Color(.black), width: .infinity)
        }
        .withPressableStyle()

    }
}

#Preview {
    ButtonStyles()
}


struct PressableButtonStyle: ButtonStyle {
    
    let scaledAmount: CGFloat
    
    init(scaledAmount: CGFloat) {
        self.scaledAmount = scaledAmount
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaledAmount : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

extension View {
    
    func withPressableStyle(scaledAmount: CGFloat = 0.9) -> some View {
        self.buttonStyle(PressableButtonStyle(scaledAmount: scaledAmount))
    }
    
    func withDefaultContinueButton(
        backgroundColor: Color = Color("MainColor"),
        strokeColor: Color = Color("MainColor"),
        shadowColor: Color = Color("MainColor"),
        width: CGFloat? = nil) -> some View {
        modifier(DefaultContinueButton(backgroundColor: backgroundColor, strokeColor: strokeColor, shadowColor: shadowColor, width: width))
    }
}


struct DefaultContinueButton: ViewModifier {
    
    let backgroundColor: Color
    let strokeColor: Color
    let shadowColor: Color
    let width: CGFloat?
    
    func body(content: Content) -> some View {
        
        if let fixedWidth = width {
            content
                .padding()
                .font(.title2).bold()
                .frame(width: fixedWidth)
                .background(backgroundColor)
                .cornerRadius(15)
                .shadow(color: shadowColor, radius: 20, x: 0.0, y: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(strokeColor, lineWidth: 3)
                )
        } else {
            content
                .padding()
                .font(.title2).bold()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(15)
                .shadow(color: shadowColor, radius: 20, x: 0.0, y: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(strokeColor, lineWidth: 3)
                )
        }
    }
}


struct ResetPasswordButton: ViewModifier {
    
    let backgroundColor: Color
    let strokeColor: Color
    let foregroundStyle: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundStyle)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .cornerRadius(15)
            .background(
                backgroundColor
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(strokeColor, lineWidth: 3)
                )
    }
}

extension View {
    func resetPasswordButtonStyle(backgroundColor: Color, strokeColor: Color, foregroundStyle: Color) -> some View {
        modifier(ResetPasswordButton(backgroundColor: backgroundColor, strokeColor: strokeColor, foregroundStyle: foregroundStyle))
    }
}
