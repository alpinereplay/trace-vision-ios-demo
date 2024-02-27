//
//  GalleryView.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 2/8/24.
//

import Foundation
import SwiftUI
import TraceVisionSDK


/// Simple multicolumn gallery view based on LazyVGrid
struct GalleryView: View {
    var items: [HighlightObject]

    @Binding
    var selectedItemIdx: Int?

    var body: some View {
        ScrollView() {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 2)], spacing: 2) {
                ForEach(0..<items.count, id: \.self) { idx in
                    HighlightCard(content: items[idx])
                        .onTapGesture {
                            selectedItemIdx = idx
                        }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

/// Gird card that shows the highlight thumbnail
struct HighlightCard: View {
    
    let content: HighlightObject
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(TraceColors.charcoalNormal10)
                .aspectRatio(1, contentMode: .fit)
            GeometryReader { geom in
                // Image is loaded from local storage using `HighlightObject.thumbnailURL`
                Image(local: content.thumbnailURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geom.size.width, height: geom.size.height)
                    .clipped()
            }
            // Jersey number is displayed in the bottom right corner
            // if it was detected in the highlight
            if let jerseyNumber = content.jerseyNumber {
                Text("#\(jerseyNumber)")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(TraceFonts.body1b)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
            }
        }
    }
}
