//
//  ImportedVideoProcessView.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/21/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import TraceVisionSDK
import AVFoundation
import Combine

struct ImportedVideoProcessView: View {
    let session: VideoImportSessionProtocol
    let provider: NSItemProvider?
    
    @StateObject
    private var status = VideoImportStatus()
    
    @State
    private var isLoading = true
    
    var closeBar: some View {
        HStack {
            Spacer()
            Button(action: close) {
                Image(systemName: "xmark")
            }.buttonStyle(MainButtonStyle(paddingSides: 40,
                                          paddingVertical: 40,
                                          circle: true,
                                          desiredBackColor: TraceColors.charcoalNormal30.opacity(0.5),
                                          desiredFrontColor: TraceColors.whiteNeutral2
                                         ))
        }.padding(.bottom, 16)
    }
    
    var titleAndProgressArea: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isLoading ? "Loading video..." : "Finding highlights...")
                    .font(TraceFonts.htitle1d)
                    .foregroundStyle(TraceColors.whiteNeutral2)
                Spacer()
            }
            ProgressView(value: status.progress, total: 1) {
                Text("Estimated \(formattedRemaining) remaining…")
                    .padding(.bottom, 8)
                    .foregroundStyle(TraceColors.whiteNeutral2)
            }
            .padding(.bottom, 40)
            .padding(.top, 16)
            .accentColor(TraceColors.whiteNeutral2)
        }
    }
    
    var loadingTitleArea: some View {
        HStack {
            Text("Loading video...")
                .font(TraceFonts.htitle1d)
                .foregroundStyle(TraceColors.whiteNeutral2)
            Spacer()
        }.padding(.bottom, 70)
    }
    
    var countArea: some View {
        HStack {
            Text("\(status.highlightsFound)")
                .font(TraceFonts.htitle1d)
                .foregroundStyle(TraceColors.whiteNeutral2)
            Spacer()
        }.padding(.top, 40)
    }
    
    var subtitleArea: some View {
        HStack {
            if status.processing == true {
                Text("highlight\(status.highlightsFound != 1 ? "s" : "") created so far")
                    .font(TraceFonts.body1sb)
                    .foregroundStyle(TraceColors.whiteNeutral2)
            } else {
                Text("highlight\(status.highlightsFound != 1 ? "s" : "") created")
                    .font(TraceFonts.htitle1d)
                    .foregroundStyle(TraceColors.whiteNeutral2)
            }
            Spacer()
        }.padding(.top, 4)
    }
    
    var bottomButtonArea: some View {
        VStack(spacing: 0) {
            if status.highlightsFound > 0 {
                Button(action: {
                    NavigationFlow.shared.navigate(dest:
                                                    NavigationParams(.videoPlayer)
                        .add(param: "items", value: status.highlights)
                        .add(param: "index", value: 0))
                }) {
                    Text("Watch now")
                }.padding(.bottom, 8)
            }
            Button(role: .cancel, action: close) {
                Text("Close")
            }
        }
    }

    var emptyPreviewArea: some View {
        GeometryReader { geom in
            ZStack {
                Expander()
                    .background(RoundedRectangle(cornerRadius: 16)
                        .fill(TraceColors.whiteNeutral1.opacity(0.3)))
                LoadingView()
            }.frame(width: geom.size.width, height: geom.size.width*9/16)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    var imagePreviewArea: some View {
        GeometryReader { geom in
            ZStack {
                if let thumb = status.previewImage {
                    Image(uiImage: thumb).resizable().scaledToFill()
                        .frame(height: geom.size.width*9/16)
                        .clipped()
                        .blur(radius: 5)
                    Image(uiImage: thumb).resizable().scaledToFit()
                }
                if status.processing == true {
                    Expander()
                        .background(RoundedRectangle(cornerRadius: 16)
                            .fill(status.previewImage != nil
                                  ? TraceColors.tealNormal50.opacity(0.75)
                                  : TraceColors.whiteNeutral1.opacity(0.3)
                                 ))
                    LoadingView()
                }
            }.frame(width: geom.size.width, height: geom.size.width*9/16)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }.aspectRatio(16/9, contentMode: .fit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            closeBar
            if isLoading {
                loadingTitleArea
                emptyPreviewArea
            } else {
                if status.processing == true {
                    titleAndProgressArea
                }
                imagePreviewArea
                countArea
                subtitleArea
                Spacer()
                if status.processing == false {
                    bottomButtonArea
                }
            }
        }
        .padding(16)
        .background(TraceColors.redNormal50)
        .toolbar(.hidden)
        .onViewDidLoad {
            onLoad()
        }
        .onChange(of: status.processing) { val in
            if val != nil {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }

    @State
    var progressCancel: AnyCancellable?
    
    func onLoad() {
        _ = provider?.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier)
        { (url, err) in
            guard let url = url else { return }
            alog.debug("LOADING URL \(url.path())")
            session.importVideo(fromFile: url, useInPlace: false)
            alog.debug("LOADING is done")
            session.setStatusObject(status)
            session.start()
        }
    }
    func close() {
        session.stop()
        NavigationFlow.shared.backToRoot()
    }
    
    private var formattedRemaining: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: status.timeRemaining) ?? ""
    }
}

#Preview {
    ImportedVideoProcessView(session: TraceVision.shared.createVideoImportSession(),provider: nil).traceDefaults()
}
