//
//  UserDefaultsManager.swift
//  todo
//
//  Created by Gheorghe on 22.09.2024.
//

import Foundation

struct UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func saveNewItem(_ item: ToDo, completion: @escaping(Error?) -> Void) {
        if let savedItems = UserDefaults.standard.object(forKey: "todoList") as? Data {
            if var loadedItems = try? decoder.decode([ToDo].self, from: savedItems) {
                
                if let index = loadedItems.firstIndex(where: { $0.id == item.id }) {
                    loadedItems[index] = item
                } else {
                    loadedItems.append(item)
                }
                
                if let encoded = try? encoder.encode(loadedItems) {
                    self.pushToDefaults(data: encoded, key: "todoList")
                } else {
                    completion("Could not save item" as? Error)
                }
            }
        } else {
            if let encoded = try? encoder.encode([item]) {
                self.pushToDefaults(data: encoded, key: "todoList")
            } else {
                completion("Could not save item" as? Error)
            }
        }
    }
    
    func deleteTodoItem(id: UUID) {
        if let savedItems = UserDefaults.standard.object(forKey: "todoList") as? Data {
            if let loadedItems = try? decoder.decode([ToDo].self, from: savedItems) {
                let items = loadedItems.filter { $0.id != id }
                if let encoded = try? encoder.encode(items) {
                    self.pushToDefaults(data: encoded, key: "todoList")
                }
            }
        }
    }
    
    func getToDoList() -> [ToDo] {
        if let savedItems = UserDefaults.standard.object(forKey: "todoList") as? Data {
            if let loadedItems = try? decoder.decode([ToDo].self, from: savedItems) {
                return loadedItems
            }
        }
        return []
    }
    
    private func pushToDefaults(data: Data, key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
}
