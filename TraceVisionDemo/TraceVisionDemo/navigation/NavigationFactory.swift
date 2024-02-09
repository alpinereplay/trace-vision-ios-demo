//
//  NavigationFactory.swift
//  TraceAction
//
//  Copyright (c) AlpineReplay 2023
//  Created by Leo Khramov on 12/6/23.
//

import Foundation
import SwiftUI
import TraceVisionSDK

class NavigationFactory {
    static let shared = NavigationFactory()
    
    @ViewBuilder
    func viewForDest(param: NavigationParams)-> some View {
        switch param.dest {
        case .main:
            MainView()
        case .videoRecorder:
            VideoRecorderView()
        case .importVideoProcessor:
            if let provider = param.params["provider"] as? NSItemProvider,
               let session = param.params["session"] as? VideoImportSessionProtocol {
                ImportedVideoProcessView(session: session, provider: provider)
            }
        case .videoPlayer:
            if let items = param.params["items"] as? [HighlightObject],
               let idx = param.params["index"] as? Int
            {
                VideoPlayerView(items: items, initialIdx: idx)
            }

            default:
                EmptyView()
        }
    }
}
