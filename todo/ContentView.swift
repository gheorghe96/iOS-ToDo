//
//  ContentView.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var toDoList: [ToDo] = []
    @State private var notificationManager = NotificationsManager()
    
    var body: some View {
        VStack {
            List {
                ForEach(self.toDoList.filterToday()) { todo in
                    NavigationLink(destination: CreateToDoView(todo: todo, onDeletePress: { id in
                        self.deleteToDo(id: id)
                    }), label: {
                        Text(todo.title)
                            .swipeActions {
                                Button("Delete") {
                                    self.deleteToDo(id: todo.id!)
                                }
                                .tint(.red)
                            }
                    })
                }
                
                Section("Tomorrow") {
                    ForEach(self.toDoList.filterTomorrow()) { todo in
                        NavigationLink(destination: CreateToDoView(todo: todo, onDeletePress: { id in
                            self.deleteToDo(id: id)
                        }), label: {
                            Text(todo.title)
                                .swipeActions {
                                    Button("Delete") {
                                        self.deleteToDo(id: todo.id!)
                                    }
                                    .tint(.red)
                                }
                        })
                    }
                }
                
                Section("Upcoming") {
                    ForEach(self.toDoList.filterUpcoming()) { todo in
                        NavigationLink(destination: CreateToDoView(todo: todo, onDeletePress: { id in
                            self.deleteToDo(id: id)
                        }), label: {
                            Text(todo.title)
                                .swipeActions {
                                    Button("Delete") {
                                        self.deleteToDo(id: todo.id!)
                                    }
                                    .tint(.red)
                                }
                        })
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            self.fetchToDoList()
        }
        .navigationBarItems(
            trailing:
                NavigationLink(destination: CreateToDoView(), label: {
                    Image(systemName: "plus")
                })
        )
        .navigationTitle("Today")
    }
    
    private func fetchToDoList() {
        self.toDoList = UserDefaultsManager().getToDoList()
    }
    
    private func deleteToDo(id: UUID) {
        UserDefaultsManager().deleteTodoItem(id: id)
        self.notificationManager.removePendingNotification(identifier: id.uuidString)
        self.fetchToDoList()
    }
}

#Preview {
    ContentView()
}
