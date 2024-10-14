//
//  ToDo.swift
//  todo
//
//  Created by Gheorghe on 22.09.2024.
//

import Foundation
import FirebaseFirestore

enum Priority: String, Codable, CaseIterable {
    case normal = "Normal"
    case low = "low"
    case hight = "hight"
}

struct CheckItem: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var isChecked: Bool
    
    init(text: String) {
        self.id = randomString(length: 28)
        self.text = text
        self.isChecked = false
        
        func randomString(length: Int) -> String {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
        }
    }
}

struct ToDo: Identifiable, Codable {
    var id: String?
    var title: String;
    var description: String;
    var priority: Priority;
    var date: Date?
    var checkList: [CheckItem]
    
    init() {
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
        self.id = randomString(length: 28)
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let id = self.id {
            dictionary["id"] = id
        }
        dictionary["title"] = self.title
        dictionary["description"] = self.description
        dictionary["priority"] = self.priority.rawValue
        if let date = self.date {
            dictionary["date"] = Timestamp(date: date)
        }
        dictionary["checkList"] = self.checkList.map { item in
            return [
                "id": item.id,
                "text": item.text,
                "isChecked": item.isChecked
            ]
        }
        return dictionary
    }
    
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
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
    
    public mutating func removeFromCheckList(id: String) {
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
