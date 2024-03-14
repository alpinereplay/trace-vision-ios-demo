//
//  VideoPlayerView.swift
//  TraceAction
//
//  Created by Leo Khramov on 1/16/24.
//  Copyright © 2024 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import TraceVisionSDK
import SwiftUI

/// View for playing  a list of video highlights
struct VideoPlayerView: View {
    
    /// Highlight Video player
    @State
    var player: HighlightVideoPlayer?
    
    /// list of highlights
    let items: [HighlightObject]

    /// Current index we are playing, points to the `items` entry
    let initialIdx: Int
    
    @State
    var toast: Toast? = nil
    
    /// Export video crop format. It changes with the screen geometry.
    @State
    var cropFormat: HighlightCropFormat = .squared
    
    var closeBar: some View {
        HStack {
            Spacer()
            Button(action: close) {
                Image(systemName: "xmark")
            }.buttonStyle(MainButtonStyle(paddingSides: 50,
                                          paddingVertical: 50,
                                          circle: true,
                                          desiredBackColor: TraceColors.charcoalNormal30.opacity(0.5),
                                          desiredFrontColor: TraceColors.whiteNeutral2
                                         ))
        }.zIndex(1.0)
    }

    var saveBar: some View {
        HStack {
            Spacer()
            Button(action: save) {
                Image(systemName: "square.and.arrow.down").fontWeight(.bold)
            }.buttonStyle(MainButtonStyle(paddingSides: 50,
                                          paddingVertical: 50,
                                          circle: true,
                                          desiredBackColor: TraceColors.charcoalNormal30.opacity(0.5),
                                          desiredFrontColor: TraceColors.whiteNeutral2
                                         ))
        }.zIndex(1.0)
    }

    
    var body: some View {
        ZStack {
            Expander()
            GeometryReader { geom in
                videoPlayer(for: geom)
            }
            .zIndex(0)
            .onSwipe(up: { value in
                if abs(value) > 30 {
                    alog.debug("Swipe UP detected")
                    player?.playNext()
                }
            },
                     down: { value in
                if abs(value) > 30 {
                    alog.debug("Swipe DOWN detected")
                    player?.playPrev()
                }
            })
            VStack {
                closeBar
                Spacer()
                saveBar
            }
            .padding(.top, 50)
            .padding(.bottom, 32)
            .padding(.horizontal, 24)
            .zIndex(1.0)
        }
        .background(TraceColors.charcoalNormal50)
        .ignoresSafeArea()
        .onViewDidLoad {
            player = HighlightVideoPlayer(items: items)
            player?.play(itemIdx: initialIdx)
        }
        .onDisappear() {
            player?.pause()
        }
        .toast($toast)
        .toolbar(.hidden)
    }

    func videoPlayer(for geom: GeometryProxy)-> some View {
        // Adjust crop format based on the screen geometry
        if geom.size.height > geom.size.width && cropFormat != .portrait {
            onMain {
                cropFormat = .portrait
            }
        } else if geom.size.height < geom.size.width && cropFormat != .landscape {
            onMain {
                cropFormat = .landscape
            }
        }
        
        return VideoPlayerPreview(player: player, visibleSize: geom.size)
    }
    
    func close() {
        NavigationFlow.shared.backToRoot()
    }
    
    func save() {
        guard let highlight = player?.currentHighlight else { return }
        toast = Toast(icon: "square.and.arrow.down", message: "Saving highlight....")
        Task.init {
            // Save the highlights in the desired format to the camera roll
            if await highlight.saveVideo(toCameraRoll: true, cropFormat: cropFormat, debug: true) != nil {
                toast = Toast(icon: "checkmark.square", message: "Saved to Camera Roll")
            } else {
                toast = Toast(icon: "exclamationmark.triangle", message: "Something went wrong.",
                              background: TraceColors.redNormal10, foreground: TraceColors.redNormal50)
            }
        }
    }
}
