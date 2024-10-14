//
//  ContentView.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authenticationManager = AuthenticationManager.shared
    @State private var toDoList: [ToDo] = []
    @State private var notificationManager = NotificationsManager()
    @State private var syncManager = SyncManager()
    
    var userLoggedIn: Bool {
        return authenticationManager.user != nil
    }
    
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
        .onChange(of: userLoggedIn) {
            if userLoggedIn {
                self.syncToDoList()
            }
        }
        .onAppear {
            self.fetchToDoList()
            self.syncToDoList()
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
    
    private func syncToDoList() {
        if let user = self.authenticationManager.user {
            UserDefaultsManager().getToDoList().forEach { todo in
                SyncManager().pushToStorage(uid: user.uid, item: todo)
            }
            
            SyncManager().pullFromStorage(uid: user.uid) { todoArray in
                todoArray.forEach { todo in
                    UserDefaultsManager().saveNewItem(todo) { error in
                        if let error {
                            print(error)
                            return
                        }
                    }
                    self.fetchToDoList()
                }
            }
        }
    }
    
    private func deleteToDo(id: String) {
        UserDefaultsManager().deleteTodoItem(id: id)
        self.notificationManager.removePendingNotification(identifier: id)
        
        if let user = authenticationManager.user {
            SyncManager().removeFromStorage(uid: user.uid, itemId: id)
        }
    }
}

#Preview {
    ContentView()
}
