//
//  AuthenticationManager.swift
//  todo
//
//  Created by Gheorghe on 11.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private var authStateHandle: AuthStateDidChangeListenerHandle!
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    @Published var user: User? = nil
    
    init() {
        self.configureAuthStateChanges()
    }
    
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            
            if let uid = user?.uid {
                print("User logged in: \(uid)")
            } else {
                self.signInAnonymously()
            }
        }
    }
    
    private func signInAnonymously() {
        auth.signInAnonymously { result, error in
            if let error {
                print("Error signing in anonymously: \(error)")
                return
            }
            if let user = result?.user {
                self.initUserProfile(uid: user.uid)
            }
        }
    }
    
    private func initUserProfile(uid: String) {
        firestore.collection("users").document(uid).setData([
            "uid": uid
        ]) { error in
            if let error {
                print(error.localizedDescription)
                return
            } else {
                print("New user profile initialized")
            }
        }
    }
}
