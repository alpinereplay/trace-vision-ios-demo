//
//  HighlightGallery.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 3/5/24.
//

import Foundation
import SwiftUI
import TraceVisionSDK

/// The HighlightsGallery struct is a SwiftUI view designed to display a gallery of highlight items, potentially filtered by certain criteria such as jersey numbers and dates.
struct HighlightsGallery: View {
    
    /// A HighlightReader object used to retrieve highlight items from the SDK.
    let reader = TraceVision.shared.getHighlightReader()
    
    /// An array of HighlightObject. This state variable stores the collection of highlight items that are displayed in the gallery. It is initially an empty array and is populated asynchronously.
    @State
    var items = [HighlightObject]()
    
    @State
    var loading = true

    /// An optional integer that tracks the index of the currently selected highlight item. It is used to navigate to detailed views of a selected highlight.
    @State
    var selectedIdx: Int?

    /// An array of optional integers representing jersey numbers used to filter the highlights. This allows the gallery to display only highlights related to specific players.
    @State
    var jnFilter: [Int?] = []
    
    /// An array of Date objects used to filter the highlights by their date. This enables the display of highlights from specific time periods.
    @State
    var dateFilter: [Date] = []

    var body: some View {
        ZStack {
            Expander()
            if loading {
                VStack {
                    Image("vision_logo")
                        .padding(.bottom, 50)
                    LoadingView()
                }
                .padding(50)
            } else {
                if items.isEmpty {
                    VStack {
                        Text("No highlights detected.\nPlease click '+' button to start your journey.").font(TraceFonts.htitle4b)
                    }
                    .padding(50)
                } else {
                    GalleryView(items: items, selectedItemIdx: $selectedIdx)
                }
                FiltersView(reader: reader, jnFilter: $jnFilter, dateFilter: $dateFilter)
            }
        }
        .task {
            // Load highlights when the view is first displayed
            await loadHighlights(jnFilter: jnFilter, dates: dateFilter)
        }
        .onChange(of: selectedIdx) { idx in
            if let idx = idx, !items.isEmpty {
                // Navigate to the video player view with the selected highlight item
                NavigationFlow.shared.navigate(dest:
                                                NavigationParams(.videoPlayer)
                    .add(param: "items", value: items)
                    .add(param: "index", value: idx))
            }
        }
        .onAppear {
            selectedIdx = nil
        }
        .onChange(of: jnFilter) { val in
            // Load highlights with the new jersey number filter
            Task.init { await loadHighlights(jnFilter: val, dates: dateFilter) }
        }
        .onChange(of: dateFilter) { val in
            // Load highlights with the new date filter
            Task.init { await loadHighlights(jnFilter: jnFilter, dates: val) }
        }
    }
    
    /// Asynchronous function is responsible for loading and filtering highlights based on the specified jersey numbers and dates. It checks if the SDK is initialized and then retrieves the highlights accordingly, updating the items state variable and the loading state.
    ///
    /// - Parameters:
    ///  - jnFilter: An array of optional integers representing jersey numbers used to filter the highlights.
    ///  - dates: An array of Date objects used to filter the highlights by their date.
    func loadHighlights(jnFilter: [Int?], dates: [Date]) async {
        if TraceVision.shared.isSDKInited == true {
            // Load highlights from the SDK and update the items state variable
            items = await TraceVision.shared
                .getHighlightReader().highlightsBy(groups: nil,
                                                   jerseyNumbers: jnFilter,
                                                   dateFrom: dates.first,
                                                   dateTo: dates.last)
            withAnimation {
                loading = false
            }
        } else {
            withAnimation {
                items = []
                loading = false
            }
        }
    }
}

