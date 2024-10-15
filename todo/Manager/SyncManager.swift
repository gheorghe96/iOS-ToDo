//
//  SyncManager.swift
//  todo
//
//  Created by Gheorghe on 11.10.2024.
//

import Foundation
import FirebaseFirestore

class SyncManager: Observable {
    private let firestore = Firestore.firestore()
    
    func pushToStorage(uid: String, item: ToDo) {
        firestore.collection("users").document(uid).collection("todo").document(item.id!).setData(item.toDictionary()) { error in
            if let error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func removeFromStorage(uid: String, itemId: String) {
        firestore.collection("users").document(uid).collection("todo").document(itemId).delete() { error in
            if let error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func pullFromStorage(uid: String, completion: @escaping([ToDo]) -> Void) {
        firestore.collection("users").document(uid).collection("todo").getDocuments() { querySnapshot, error in
            if let error {
                print(error.localizedDescription)
                return
            } else {
                guard let documents = querySnapshot?.documents else {
                    return
                }
                
                let resp = documents.compactMap({ querySnapshot in
                    let doc = try? querySnapshot.data(as: ToDo.self)
                    return doc
                })
                
                completion(resp)
            }
        }
    }
}
