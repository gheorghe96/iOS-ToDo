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

struct CheckItem: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var isChecked: Bool = false
}

struct ToDo: Identifiable, Codable, Hashable {
    var id: UUID?
    var title: String;
    var description: String;
    var priority: Priority;
    var date: Date?
    var checkList: [CheckItem]
    
    init() {
        self.id = nil
        self.title = "";
        self.description = "";
        self.priority = .normal
        self.checkList = []
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
    
    public mutating func addToCheckList() {
        if let lastItem = self.checkList.last {
            if (!lastItem.text.isEmpty) {
                self.checkList.append(CheckItem(text: ""))
            }
        } else {
            self.checkList.append(CheckItem(text: ""))
        }
    }
    
    public mutating func removeFromCheckList(id: UUID) {
        if let index = self.checkList.firstIndex(where: {$0.id == id}) {
            self.checkList.remove(at: index)
        }
    }
    
    mutating func save(completion: @escaping(Error?) -> Void) {
        UserDefaultsManager().saveNewItem(self) { error in
            completion(error)
        }
    }
}
