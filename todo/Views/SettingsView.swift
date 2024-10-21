//
//  SettingsView.swift
//  todo
//
//  Created by Gheorghe on 20.10.2024.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        Form {
            Section("General") {
                NavigationLink(destination: Text("Languages View"), label: {
                    SettingsListItem(title: "Languages", value: "English")
                })
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
