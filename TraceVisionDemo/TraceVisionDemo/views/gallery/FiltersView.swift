//
//  FiltersView.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 3/5/24.
//

import Foundation
import SwiftUI
import TraceVisionSDK

/// The FiltersView struct is a SwiftUI component designed for filtering highlight items by jersey numbers and dates within a user interface that leverages the TraceVisionSDK. This view encapsulates both jersey number and date filters, providing a user-friendly mechanism to refine which highlights are shown.
///
/// - Tapping on the jersey number or date filter sections opens their respective picker views (``JerseyPicker`` and ``DateIntervalPicker``), allowing users to change their selections.
/// - A button toggles the visibility of the filter options, changing its icon based on the filterOpened state.
struct FiltersView: View {
    /// An instance of `HighlightReaderProtocol` used for fetching data related to highlights, such as available jersey numbers.
    let reader: HighlightReaderProtocol
    
    @State
    var filterOpened = false
    
    /// A binding to an array of optional integers, representing selected jersey numbers for filtering highlights. This allows for dynamic changes from parent views or components.
    @Binding
    var jnFilter: [Int?]
    
    /// A binding to an array of Date objects, specifying the date range for filtering highlights.
    @Binding
    var dateFilter: [Date]
    
    @State
    var dateString = "0_all"
    
    @State
    var datePickerOpened = false
    
    @State
    var dateFrom: Date = Date()
    
    @State
    var jnPickerOpened = false
    
    var filters: some View {
        ZStack {
            HStack {
                Spacer()
            }
            HStack(spacing: 8) {
                Text("JN:")
                    .font(TraceFonts.body1b)
                    .foregroundColor(TraceColors.whiteNeutral1.opacity(0.75))
                    .padding(.leading, 16)
                Text(jnFilterString)
                    .font(TraceFonts.body1r)
                    .foregroundColor(TraceColors.whiteNeutral1.opacity(0.75))
                    .frame(maxHeight: 48)
                    .frame(width: 36)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3)))
                    .onTapGesture {
                        jnPickerOpened = true
                    }
                Text("Date:")
                    .font(TraceFonts.body1b)
                    .foregroundColor(TraceColors.whiteNeutral1.opacity(0.75))
                    .padding(.leading, 16)
                Text((DateIntervalPicker.DATE_PICKER_VALUES[dateString] ?? ("", "All")).1)
                    .font(TraceFonts.body1r)
                    .foregroundColor(TraceColors.whiteNeutral1.opacity(0.75))
                    .frame(maxHeight: 48)
                    .frame(width: 36)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3)))
                    .onTapGesture {
                        datePickerOpened = true
                    }
                Spacer()
            }
        }
    }
    
    var jnFilterString: String {
        if jnFilter.isEmpty {
            return "All"
        }
        
        if jnFilter.count == 1, jnFilter[0] == nil {
            return "No JN"
        }
        
        let str = jnFilter[0..<min(jnFilter.count, 3)].map { $0 == nil ? "No JN" : String($0!) }.joined(separator: ", ")
        return str + (jnFilter.count > 3 ? " ..." : "")
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                if filterOpened {
                    filters
                        .frame(height: 48)
                }
                Button(role: .none, action: {
                    withAnimation { filterOpened = !filterOpened }
                }) {
                    Image(systemName: filterOpened
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                        .font(Font.system(size: 24, weight: .regular))
                }.buttonStyle(MainButtonStyle(paddingSides: 48,
                                              paddingVertical: 48,
                                              circle: true,
                                              desiredBackColor: Color.black.opacity(0.3),
                                              desiredFrontColor: TraceColors.whiteNeutral1.opacity(0.75)))
            }
            .background(RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.3)))
            HStack {
                Spacer()
            }
            Spacer()
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 32)
        .sheet(isPresented: $datePickerOpened) {
            DateIntervalPicker(dateFilter: $dateFilter, dateString: $dateString, pickerOpened: $datePickerOpened)
                .traceDefaults().presentationDetents([.height(300)])
        }
        .sheet(isPresented: $jnPickerOpened) {
            JerseyPicker(reader: reader, jnFilter: $jnFilter, pickerOpened: $jnPickerOpened)
                .traceDefaults().presentationDetents([.height(400)])
        }
    }
}


