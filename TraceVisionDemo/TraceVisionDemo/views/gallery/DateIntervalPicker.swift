//
//  DateIntervalPicker.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 3/5/24.
//

import Foundation
import SwiftUI

/// The DateIntervalPicker struct is a SwiftUI view component designed to allow users to select date ranges from a list for filtering purposes.
struct DateIntervalPicker: View {
    @Binding
    var dateFilter: [Date]
    
    @Binding
    var dateString: String
    
    @Binding
    var pickerOpened: Bool
    
    static let DATE_PICKER_VALUES: [String: (String, String)] = [
        "0_all": ("All", "All"),
        "1_today": ("Today", "Now"),
        "2_yesterday": ("Yesterday", "Yst"),
        "3_last7": ("Last 7 days", "7d"),
        "4_last30": ("Last 30 days", "30d"),
    ]
        
    var body: some View {
        ScrollView {
            VStack {
                Text("Select date range")
                    .font(TraceFonts.htitle3d)
                    .padding(.top, 16)
                ForEach(DateIntervalPicker.DATE_PICKER_VALUES.keys.sorted(), id: \.self) { key in
                    Button(role: .cancel, action: {
                        setDates(key: key)
                        pickerOpened = false
                    }) {
                        HStack {
                            Text((DateIntervalPicker.DATE_PICKER_VALUES[key] ?? ("", "")).0)
                            Spacer()
                            if key == dateString {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(MainButtonStyle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 32)
                }
            }
        }
    }
    
    func setDates(key: String) {
        dateString = key
        switch key {
        case "0_all":
            dateFilter = []
        case "1_today":
            dateFilter = [Calendar.current.startOfDay(for: Date()),
                          Calendar.current.startOfDay(for: Date().addingTimeInterval(24 * 60 * 60))]
        case "2_yesterday":
            dateFilter = [Calendar.current.startOfDay(for: Date().addingTimeInterval(-24 * 60 * 60)),
                          Calendar.current.startOfDay(for: Date())]
        case "3_last7":
            dateFilter = [Calendar.current.startOfDay(for: Date().addingTimeInterval(-7 * 24 * 60 * 60)),
                          Calendar.current.startOfDay(for: Date().addingTimeInterval(24 * 60 * 60))]
        case "4_last30":
            dateFilter = [Calendar.current.startOfDay(for: Date().addingTimeInterval(-30 * 24 * 60 * 60)),
                          Calendar.current.startOfDay(for: Date().addingTimeInterval(24 * 60 * 60))]
        default:
            break
        }
    }
}

