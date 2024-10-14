//
//  todoApp.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct todoApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var authenticationManager: AuthenticationManager?
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .onAppear {
                self.authenticationManager = AuthenticationManager()
            }
        }
    }
}
