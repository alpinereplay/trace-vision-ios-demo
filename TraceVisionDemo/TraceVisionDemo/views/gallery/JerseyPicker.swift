//
//  JerseyPicker.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 3/5/24.
//

import Foundation
import SwiftUI
import TraceVisionSDK

/// The JerseyPicker struct is a SwiftUI view component designed to allow users to select jersey numbers from a list for filtering purposes. It interacts with the TraceVisionSDK to fetch and display jersey numbers associated with saved highlights.
///
/// User Interaction and Feedback:
/// - The jersey numbers are displayed in a list where each item can be tapped to toggle its selection state. A checkmark indicates selected items.
/// - Two buttons at the bottom allow users to either select all jersey numbers or set the selection and close the picker.
struct JerseyPicker: View {
    /// An instance of HighlightReaderProtocol provided to the JerseyPicker upon initialization. This reader is used to fetch available jersey numbers for highlights.
    let reader: HighlightReaderProtocol

    /// A binding to an array of optional integers, representing the currently selected jersey numbers for filtering. Changes to this array reflect back to the parent view that holds the JerseyPicker.
    @Binding
    var jnFilter: [Int?]
    
    /// A binding to a Boolean value indicating whether the jersey picker view is currently open. This allows the parent view to control the visibility of the JerseyPicker.
    @Binding
    var pickerOpened: Bool
            
    /// A state variable holding an array of JerseyNumberInfo, which represents the jersey numbers fetched from the highlights.
    @State
    var items: [JerseyNumberInfo] = []
    
    /// A state variable tracking the currently selected jersey numbers within the picker.
    @State
    var selected: [Int?] = []
    
    var body: some View {
        VStack {
            Text("Pick jersey numbers")
                .font(TraceFonts.htitle3d)
                .padding(.top, 16)
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(items, id: \.self) { i in
                        HStack {
                            Text(i.jerseyNumber == nil ? "No JN" : "#\(i.jerseyNumber!)")
                                .font(TraceFonts.body1sb)
                            Spacer()
                            ZStack {
                                if selected.contains(i.jerseyNumber) {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(width: 32, height: 32)
                            .background(RoundedRectangle(cornerRadius: 6)
                                .stroke(TraceColors.tealNormal30, lineWidth: 2))
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .onTapGesture {
                            withAnimation { toggle(i) }
                        }
                    }
                }
            }
            HStack(spacing: 24) {
                Button(role: .cancel, action: {
                    setAll()
                }) {
                    Text("All")
                }.frame(width: 140)
                Button(action: {
                    done()
                }) {
                    Text("Set")
                }.frame(width: 140)
            }
        }.task {
            // Load jersey numbers when the view appears
            selected = jnFilter.map({ $0 })
            await loadJNs()
        }
    }
    
    /// Clears the current selection and updates the jnFilter to reflect that no jersey numbers are filtered.
    func setAll() {
        withAnimation {
            selected = []
        }
        jnFilter = []
        pickerOpened = false
    }
    
    /// Sets the jnFilter to match the currently selected jersey numbers and closes the picker.
    func done() {
        jnFilter = selected
        pickerOpened = false
    }
    
    /// Toggles the selection state of a jersey number. If the number is already selected, it is removed from the selected array; if not, it is added.
    func toggle(_ jn: JerseyNumberInfo) {
        if selected.contains(jn.jerseyNumber) {
            selected.removeAll(where: { $0 == jn.jerseyNumber })
        } else {
            selected.append(jn.jerseyNumber)
        }
    }
    
    /// Asynchronously loads the available jersey numbers using the provided reader and updates the items state variable to reflect the fetched jersey numbers. This function is called when the view appears, ensuring the list is populated with the latest data.
    func loadJNs() async {
        // Load a list of all available jersey numbers from the saved highlights
        let jns = await reader.availableJerseyNumbers(dateFrom: nil, dateTo: nil)
        withAnimation {
            items = jns
        }
    }
}
