//
//  CrashView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 2/3/25.
//

import SwiftUI

import FirebaseCrashlytics
import FirebaseCrashlyticsSwift

final class CrashManager {
    
    static let shared = CrashManager()
    private init() { }
    
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
}

struct CrashView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                Button("Click me 1") {
                    let myString: String? = nil
                    let string2 = myString!
                }
                
                Button("Click me 2")  {
                    fatalError("This was a fatal crash.")
                }
                Button("Click me 3") {
                    let array: [String] = []
                    let item = array[0]
                }
            }
            // AS SOON AS YOU GET AN AUTHENTICATED USER THROW THEM INTO CRASHLYTICS
            .onAppear {
                CrashManager.shared.setUserId(userId: "ABC123")
            }
        }
    }
}

#Preview {
    CrashView()
}
