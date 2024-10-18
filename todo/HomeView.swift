//
//  ContentView.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authenticationManager = AuthenticationManager.shared
    @State private var toDoList: [ToDo] = []
    @State private var notificationManager = NotificationsManager()
    @State private var syncManager = SyncManager()
    
    @State private var tabSelection = 1
    
    var userLoggedIn: Bool {
        return authenticationManager.user != nil
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        self.tabSelection = 1
                    }
                }, label: {
                    Text("ToDo")
                        .bold(self.tabSelection == 1)
                        .underline(self.tabSelection == 1)
                })
                
                Button(action: {
                    withAnimation {
                        self.tabSelection = 2
                    }
                }, label: {
                    Text("Quick notes")
                        .bold(self.tabSelection == 2)
                        .underline(self.tabSelection == 2)
                })
                
                Button(action: {
                    withAnimation {
                        self.tabSelection = 3
                    }
                }, label: {
                    Text("Projects")
                        .bold(self.tabSelection == 3)
                        .underline(self.tabSelection == 3)
                })
                
                Spacer()
            }
            .padding(.leading)
            
            TabView(selection: $tabSelection) {
                List {
                    HomeListSection(list: self.toDoList.filterToday(), onDeleteItem: { id in
                        self.deleteToDoWithId(id)
                    })
                    
                    Section("Tomorrow") {
                        HomeListSection(list: self.toDoList.filterTomorrow(), onDeleteItem: { id in
                            self.deleteToDoWithId(id)
                        })
                    }
                    
                    Section("Upcoming") {
                        HomeListSection(list: self.toDoList.filterUpcoming(), onDeleteItem: { id in
                            self.deleteToDoWithId(id)
                        })
                    }
                }
                .listStyle(.plain)
                .tag(1)
                
                Text("Coming soon")
                    .tag(2)
                Text("Coming soon")
                    .tag(3)
            }
            .tabViewStyle(.page)
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
        .navigationTitle("Home")
        .navigationBarItems(
            trailing:
                NavigationLink(destination: CreateToDoView(), label: {
                    Image(systemName: "plus")
                })
        )
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
                            print(error.localizedDescription)
                            return
                        }
                    }
                    self.fetchToDoList()
                }
            }
        }
    }
    
    private func deleteToDoWithId(_ id: String) {
        UserDefaultsManager().deleteTodoItem(id: id)
        self.notificationManager.removePendingNotification(identifier: id)
        
        if let user = authenticationManager.user {
            SyncManager().removeFromStorage(uid: user.uid, itemId: id)
        }
    }
}

#Preview {
    HomeView()
}
