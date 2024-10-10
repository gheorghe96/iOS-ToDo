//
//  ToDo+Array.swift
//  todo
//
//  Created by Gheorghe on 07.10.2024.
//

import Foundation

extension Array where Iterator.Element == ToDo {
    func filterToday() -> [ToDo] {
        var result: [ToDo] = []
        for item in self {
            if let date = item.date {
                if (Calendar.current.dateComponents([.year, .month, .day], from: date) == Calendar.current.dateComponents([.year, .month, .day], from: Date.now)) {
                    result.append(item)
                }
            }
        }
        return result
    }
    
    func filterTomorrow() -> [ToDo] {
        var result: [ToDo] = []
        for item in self {
            if let date = item.date {
                if (Calendar.current.dateComponents([.year, .month, .day], from: date) == Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!)) {
                    result.append(item)
                }
            }
        }
        return result
    }
    
    func filterThisWeek() -> [ToDo] {
        var result: [ToDo] = []
        for item in self {
            if let date = item.date {
                if (Calendar.current.dateComponents([.year, .month, .day], from: date) == Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: 7, to: Date.now)!)) {
                    result.append(item)
                }
            }
        }
        return result
    }
    
    func filterUpcoming() -> [ToDo] {
        var result: [ToDo] = []
        for item in self {
            if let date = item.date {
                if (Calendar.current.dateComponents([.year, .month, .day], from: date) != Calendar.current.dateComponents([.year, .month, .day], from: Date.now) && Calendar.current.dateComponents([.year, .month, .day], from: date) != Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!)) {
                    result.append(item)
                }
            } else {
                result.append(item)
            }
        }
        return result
    }
}
