//
//  HomeListSection.swift
//  todo
//
//  Created by Gheorghe on 15.10.2024.
//

import SwiftUI

struct HomeListSection: View {
    var list: [ToDo] = []
    var onDeleteItem: (_ id: String) -> Void
    
    var body: some View {
        ForEach(list) { todo in
            NavigationLink(destination: CreateToDoView(todo: todo, onDeletePress: { id in
                onDeleteItem(id)
            }), label: {
                HStack {
                    VStack {
                        Text(todo.title)
                            .lineLimit(1)
                        Text(todo.description)
                            .lineLimit(2)
                            .font(.system(.caption))
                    }
                }
                .swipeActions {
                    if let id = todo.id {
                        Button("Delete") {
                            onDeleteItem(id)
                        }
                        .tint(.red)
                    }
                }
            })
        }
    }
}
