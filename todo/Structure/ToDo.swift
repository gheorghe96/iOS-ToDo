//
//  ToDo.swift
//  todo
//
//  Created by Gheorghe on 22.09.2024.
//

import Foundation

enum Priority: String, Codable, CaseIterable {
    case normal = "Normal"
    case low = "low"
    case hight = "hight"
}

struct ToDo: Identifiable, Codable {
    var id: UUID?
    var title: String;
    var description: String;
    var priority: Priority;
    var date: Date?
    
    init() {
        self.id = nil
        self.title = "";
        self.description = "";
        self.priority = .normal
    }
    
    public mutating func setTitle(_ title: String) {
        self.title = title
    }
    
    public mutating func setDescription(_ description: String) {
        self.description = description
    }
    
    public mutating func setPriority(_ priority: Priority) {
        self.priority = priority
    }
    
    public mutating func setDate(_ date: Date?) {
        self.date = date
    }
    
    public mutating func setId() {
        self.id = UUID()
    }
    
    mutating func save(completion: @escaping(Error?) -> Void) {
        UserDefaultsManager().saveNewItem(self) { error in
            completion(error)
        }
    }
}
