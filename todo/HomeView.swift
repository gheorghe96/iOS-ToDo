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
            .padding([.leading])
            .padding(.top, 5)
            
            TabView(selection: $tabSelection) {
                if (self.toDoList.isEmpty) {
                    VStack {
                        Spacer()
                        LottieView(animationName: "homeEmptyList", loopMode: .loop, speed: 1.5)
                            .frame(width: 200, height: 200)
                        Text("Organize your daily tasks and reminders with eReminder")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .tag(1)
                } else {
                    List {
                        if (self.toDoList.filterToday().isEmpty == false) {
                            Section("Today") {
                                HomeListSection(list: self.toDoList.filterToday(), onDeleteItem: { id in
                                    self.deleteToDoWithId(id)
                                })
                            }
                        }
                        
                        if (self.toDoList.filterTomorrow().isEmpty == false) {
                            Section("Tomorrow") {
                                HomeListSection(list: self.toDoList.filterTomorrow(), onDeleteItem: { id in
                                    self.deleteToDoWithId(id)
                                })
                            }
                        }
                        
                        if (self.toDoList.filterUpcoming().isEmpty == false) {
                            Section("Upcoming") {
                                HomeListSection(list: self.toDoList.filterUpcoming(), onDeleteItem: { id in
                                    self.deleteToDoWithId(id)
                                })
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .tag(1)
                }
                
                if ([].isEmpty) {
                    VStack {
                        Spacer()
                        LottieView(animationName: "easyNotesEmptyList", loopMode: .loop, speed: 1.5)
                            .frame(width: 200, height: 200)
                        Text("Organize your daily tasks and reminders with eReminder")
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .tag(2)
                } else {
                    Text("Coming soon")
                        .tag(2)
                }
                
                Text("Coming soon")
                    .tag(3)
            }
            .tabViewStyle(.page)
            .background(Color(UIColor.systemBackground))
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
        .navigationTitle("Reminders")
        .navigationBarItems(
            trailing:
                HStack {
                    NavigationLink(destination: CreateToDoView(), label: {
                        Image(systemName: "plus")
                    })
                    
                    NavigationLink(destination: SettingsView(), label: {
                        Image(systemName: "gear")
                    })
                }
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
