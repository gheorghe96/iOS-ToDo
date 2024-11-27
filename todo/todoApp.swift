//
//  todoApp.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI
import FirebaseCore

var shortcutItemToProcess: UIApplicationShortcutItem?

class AppDelegate: NSObject, UIApplicationDelegate {
    // This method is called when the app finishes launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }
}

@main
struct todoApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authenticationManager: AuthenticationManager?
    
    @State private var displayNewTodoView: Bool = false
    @Environment(\.scenePhase) var phase
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .navigationDestination(isPresented: self.$displayNewTodoView) {
                        CreateToDoView()
                    }
            }
            .onChange(of: phase) {
                switch phase {
                case .active :
                    print("App in active")
                    if (shortcutItemToProcess?.type == "new_todo") {
                        self.displayNewTodoView = true
                    }
                case .inactive:
                    print("App is inactive")
                case .background:
                    print("App in Back ground")
                    addQuickActions()
                @unknown default:
                    print("default")
                }
            }
            .onAppear {
                self.authenticationManager = AuthenticationManager()
            }
        }
    }
    
    private func addQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(type: "new_todo", localizedTitle: "New Todo", localizedSubtitle: "Quickly create todo", icon: UIApplicationShortcutIcon.init(systemImageName: "plus")),
        ]
    }
}
