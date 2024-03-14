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
    let items: [HighlightObject]

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

let cardDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d/yy"
    return formatter
}()

/// Gird card that shows the highlight thumbnail
struct HighlightCard: View {
    
    let content: HighlightObject
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(TraceColors.charcoalNormal10)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(local: content.thumbnailURL)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                }
                .contentShape(Rectangle())
            
            HStack(alignment: .top, content: {
                // Date when the highlight was recorder is displayed in the top left corner
                Text("\(cardDateFormatter.string(from: content.dateRecorded))")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(TraceFonts.body2sb)
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.black).opacity(0.2))
                    .padding(6)
                Expander()
            })
            
            HStack {
                // Jersey number is displayed in the bottom right corner
                // if it was detected in the highlight
                if let jerseyNumber = content.jerseyNumber {
                    Text("#\(jerseyNumber)")
                        .foregroundStyle(.white.opacity(0.6))
                        .font(TraceFonts.body1b)
                }
                // Show a colored circle according to the highlight group, convert group to color.
                // The group prop has the same value for highlights processed in the same session.
                if content.group.count > 5 {
                    Circle().fill(content.group.substring(to: 5).color().opacity(0.75))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.white).opacity(0.8))
                }
            }.padding(8)
        }
    }
}
