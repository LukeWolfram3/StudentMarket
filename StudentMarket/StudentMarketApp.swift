//
//  StudentMarketApp.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 12/11/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

// Project is in github
//CLIENT ACCESS HAS EXPIRED-NEEDS TO BE RESET

@main
struct StudentMarketApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


    var body: some Scene {
        WindowGroup {
            PostNewItem()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
}
