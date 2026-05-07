//
//  OptionalDatePicker.swift
//  WhatsNext
//
//  Created by Tobias Sörensson on 2026-05-07.
//

import SwiftUI

struct OptionalDatePicker: View {
    let title: String
    @Binding var date: Date?
    
    var body: some View {
        Toggle(title, isOn: Binding(
            get: { date != nil },
            set: { isOn in
                date = isOn ? .now : nil
            }
        ))
        
        if let _ = date {
            DatePicker(
                "",
                selection: Binding(
                    get: { date ?? .now },
                    set: { date = $0 }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
        }
    }
}
