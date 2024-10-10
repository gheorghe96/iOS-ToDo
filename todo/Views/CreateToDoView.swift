//
//  CreateView.swift
//  todo
//
//  Created by Gheorghe on 21.09.2024.
//

import SwiftUI

struct CheckItem: Identifiable {
    var id: UUID = UUID()
    var text: String
    var isChecked: Bool = false
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 20, height: 20)
                .cornerRadius(5.0)
                .overlay {
                    if (configuration.isOn) {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
            configuration.label
        }
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .foregroundColor(.accentColor)
        .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
  }

struct CreateToDoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var notificationManager = NotificationsManager()
    @State var todo: ToDo = ToDo()
    @State private var date: Bool = false
    @State private var checkList: [CheckItem] = []
    
    var body: some View {
        VStack() {
            List {
                Section("General") {
                    TextField("Title", text: Binding(
                        get: { self.todo.title },
                        set: { newValue in
                            self.todo.setTitle(newValue)
                        }
                    ))
                }
                
                Section("Description") {
                    TextEditor(text: Binding(
                        get: { self.todo.description },
                        set: { newValue in
                            self.todo.setDescription(newValue)
                        }
                    ))
                    .frame(minHeight: 50)
                }
                
                Section("Check list") {
                    VStack(alignment: .leading) {
                        ForEach(self.$checkList) { item in
                            HStack {
                                Toggle(isOn: item.isChecked) {
                                    TextField("Some check item here", text: item.text)
                                }
                                .toggleStyle(CheckboxToggleStyle())
                                
                                Spacer()
                                Button(action: {
                                    if let index = self.checkList.firstIndex(where: {$0.id == item.id}) {
                                        self.checkList.remove(at: index)
                                    }
                                }, label: {
                                    Image(systemName: "trash")
                                        .tint(.red)
                                })
                                .buttonStyle(MyButtonStyle())
                            }
                        }
                        
                        Button(action: {
                            self.checkList.append(CheckItem(text: "", isChecked: false))
                        }, label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add new item")
                            }
                        })
                        .buttonStyle(MyButtonStyle())
                        .padding(.top)
                    }
                }
                
                Section("Additional") {
                    Picker("Priority", selection: Binding(
                        get: {self.todo.priority},
                        set: {newValue in self.todo.setPriority(newValue)}
                    )) {
                        ForEach(Priority.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Toggle("Date", isOn: $date)
                    if (self.date) {
                        DatePicker(selection: Binding(
                            get: { self.todo.date ?? Date.now },
                            set: { newValue in self.todo.setDate(newValue) }
                        ), in: Date.now..., displayedComponents: .date) {
                            Text("Select a date")
                        }
                        
                        DatePicker("Please enter a time", selection: Binding(
                            get: { self.todo.date ?? Date.now },
                            set: { newValue in self.todo.setDate(newValue) }
                        ), displayedComponents: .hourAndMinute)
                    }
                }
            }
            .listStyle(.plain)
            .onAppear {
                if (self.todo.date != nil) {
                    self.date = true
                }
            }
        }
        .navigationBarItems(
            trailing:
                Button(self.todo.id != nil ? "Update" : "Save") {
                    self.onSavePress()
                }
                .disabled(self.todo.title.isEmpty)
        )
        .navigationTitle(self.todo.id != nil ? "Edit" : "Create")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func onSavePress() {
        if (self.todo.id == nil) {
            self.todo.setId()
        }
        
        if (self.date == false) {
            self.todo.setDate(nil)
        }
        
        self.todo.save() { error in
            print(error?.localizedDescription ?? "Unknown error")
            return
        }
        
        if let id = self.todo.id {
            self.notificationManager.removePendingNotification(identifier: id.uuidString)
        }
        
        if let date = self.todo.date, let id = self.todo.id {
            var payload = NotificationPayload(id: id, date: date)
            payload.title = self.todo.title
            payload.description = self.todo.description
            payload.date = date
            self.notificationManager.scheduleNotification(payload)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}
