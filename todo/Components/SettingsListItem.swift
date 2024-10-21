//
//  SwttingsListItem.swift
//  todo
//
//  Created by Gheorghe on 20.10.2024.
//

import SwiftUI

struct SettingsListItem : View {
    var title: String
    var value: String?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundStyle(.gray)
            }
        }
    }
}
