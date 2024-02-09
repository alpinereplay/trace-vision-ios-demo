//
//  VideoRecorderView.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/18/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import TraceVisionSDK
import AVFoundation

struct VideoRecorderView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject
    var session = ObservableWrapper(TraceVision.shared.createVideoRecordSession())
    
    @State
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    @StateObject
    var videoStatus: VideoRecorderStatus = VideoRecorderStatus()
    
    @State
    var isTransitioning: Bool = false
    
    @State
    var currentMagnification: CGFloat = 0
    
    @State
    var initialZoom: CGFloat = 0
    
    @State
    var thumbs: [String] = []
    
    @State
    var animatingthumb: String? = nil
    
    @State
    var highlightsFound = 0
    
    @State
    var toast: Toast? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let isVertical = geometry.size.height > geometry.size.width
            ZStack {
                if previewLayer != nil {
                    CameraPreview(previewLayer: $previewLayer)
                        .background(TraceColors.charcoalNormal50)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { delta in
                                    if initialZoom == 0 {
                                        initialZoom = session.value.userFacingZoom
                                    }
                                    session.value.setZoom(initialZoom * ((delta - 1) * 0.7 + 1))
                                }
                                .onEnded { _ in
                                    initialZoom = 0
                                }
                        )
                        .ignoresSafeArea()
                } else {
                    Text("Initializing camera...").foregroundStyle(TraceColors.whiteNeutral1)
                }
                VStack {
                    ZStack {
                        HStack {
                            if videoStatus.processing == true {
                                HighlightCountView(count: $highlightsFound).padding(.leading, 24)
                            }
                            Spacer()
                            if videoStatus.processing != true {
                                Button(action: {
                                    fullStop()
                                    NavigationFlow.shared.backToRoot()
                                }) {
                                    Image(systemName: "xmark").fontWeight(.bold)
                                }.buttonStyle(MainButtonStyle(paddingSides: 40,
                                                              paddingVertical: 40,
                                                              circle: true,
                                                              desiredBackColor: .black.opacity(0.5),
                                                              desiredFrontColor: .white.opacity(0.7)
                                                             ))
                                .padding(.trailing, 16)
                            }
                        }
                        HStack {
                            Spacer()
                            RecordTickerView(duration: $videoStatus.duration, isRecording: $videoStatus.processing)
                                .onTapGesture {
                                    addThumb()
                                }
                            Spacer()
                        }
                    }.padding(.top, isVertical ? 0 : 20)
                    Spacer()
                }
                if isVertical {
                    VStack {
                        Spacer()
                        ZoomControlsView(recorder: session.value, videoStatus: videoStatus, isVertical: true)
                            .padding(.bottom, 40)
                        Button(action: {
                            withAnimation {
                                toggleRecording()
                            }
                        }) {
                            Image(videoStatus.processing == true ? "recording_on" : "recording_off")
                        }.buttonStyle(ImageButtonStyle(wSize: 64, hSize: 64))
                            .padding(.bottom, 24)
                            .disabled(isTransitioning)
                        
                    }
                } else {
                    HStack(alignment: .center) {
                        VStack {
                            Spacer()
                        }
                        Spacer()
                        ZoomControlsView(recorder: session.value, videoStatus: videoStatus, isVertical: false)
                            .padding(.trailing, 40)
                        Button(action: {
                            toggleRecording()
                        }) {
                            Image(videoStatus.processing == true ? "recording_on" : "recording_off")
                        }.buttonStyle(ImageButtonStyle(wSize: 64, hSize: 64))
                            .padding(.trailing, 68)
                            .disabled(isTransitioning)
                    }.ignoresSafeArea()
                }
                AnimatingThumbView(thumb: animatingthumb)
            }
            .background(TraceColors.charcoalNormal50)
            .forceRotation(orientation: .allButUpsideDown)
            .onAppear() {
                start()
            }
            .onDisappear() {
                fullStop()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    alog.debug("Active")
                } else if newPhase == .inactive {
                    alog.debug("Inactive")
                } else if newPhase == .background {
                    alog.debug("Background")
                    session.value.stopRecording()
                }
            }
            .onChange(of: videoStatus.processing) { val in
                isTransitioning = false
            }
            .onChange(of: videoStatus.isInitialized) { val in
                isTransitioning = !val
            }
            .onDeviceRotation { orientation in
                var videoO = AVCaptureVideoOrientation.portrait
                switch orientation {
                case .landscapeLeft:
                    videoO = .landscapeRight
                case .landscapeRight:
                    videoO = .landscapeLeft
                case .portraitUpsideDown:
                    videoO = .portraitUpsideDown
                default:
                    videoO = .portrait
                }
                session.value.changeVideoOrientation(videoO)
            }
            .toast($toast)
            .toolbar(.hidden)
        }
    }
    
    func addThumb() {
        thumbs.append("thumbnail_vertical")
        postThumbProcess()
    }
    
    @discardableResult
    func postThumbProcess()->Bool {
        if !thumbs.isEmpty && animatingthumb == nil {
            withAnimation {
                animatingthumb = thumbs.first
            }
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                withAnimation {
                    animatingthumb = nil
                }
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    onThumbEnd()
                }
            }
            return true
        }
        return false
    }
    
    func onThumbEnd() {
        highlightsFound += 1
        thumbs.removeFirst()
        postThumbProcess()
    }
    
    func start() {
        let recorder = session.value
        recorder.setStatusObject(videoStatus)
        recorder.initVideoRecorder(orientation: .portrait)
        previewLayer = recorder.previewLayer
    }
    
    func fullStop() {
        session.value.stopVideoRecorder()
    }
    
    func toggleRecording() {
        isTransitioning = true
        if videoStatus.processing == true {
            session.value.stopRecording()
            if highlightsFound > 0 {
                toast = Toast(icon: "checkmark", message: "\(highlightsFound) highlight\(highlightsFound>1 ? "s" : "") created from recording")
                highlightsFound = 0
            }
        } else {
            session.value.startRecording()
        }
    }
}

#Preview {
    VideoRecorderView().traceDefaults()
}

struct HighlightCountView: View {
    @Binding
    var count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "play.rectangle.on.rectangle")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading, 8)
            Text("\(count)")
                .foregroundStyle(TraceColors.whiteNeutral2)
                .font(TraceFonts.body2sb)
        }
    }
}

struct RecordTickerView: View {
    @Binding
    var duration: TimeInterval
    
    @Binding
    var isRecording: Bool?
    
    var body: some View {
        Text(formattedDuration)
            .font(TraceFonts.htitle4l)
            .foregroundStyle(TraceColors.whiteNeutral2)
            .padding(4)
            .background(RoundedRectangle(cornerRadius: 4)
                .fill(isRecording == true ? TraceColors.errorRegular : .black.opacity(0.75)))
    }
            
    private var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }
}


struct ZoomControlsView: View {
    @State
    var recorder: VideoRecordSessionProtocol
    
    @ObservedObject
    var videoStatus: VideoRecorderStatus
    
    let isVertical: Bool
    
    var body: some View {
        let zThresholds: [CGFloat] = recorder.userFacingZoomThresholds
        let levels = zThresholds.count
        let currentLevelIdx = zoomButtonIdx(for: videoStatus.zoom, in: zThresholds)
        if isVertical {
            HStack {
                ForEach(0..<levels, id: \.self) { val in
                    let threshold = zThresholds[val]
                    let thisLevel = val == currentLevelIdx
                    buttonBody(threshold: threshold, thisLevel: thisLevel)
                }
            }
            .padding(4)
            .background(Capsule().fill(.black.opacity(0.5)))
        } else {
            VStack {
                ForEach((0..<levels).reversed(), id: \.self) { val in
                    let threshold = zThresholds[val]
                    let thisLevel = val == currentLevelIdx
                    buttonBody(threshold: threshold, thisLevel: thisLevel)
                }
            }
            .padding(4)
            .background(Capsule().fill(.black.opacity(0.5)))
        }
    }

    @ViewBuilder
    func buttonBody(threshold: CGFloat, thisLevel: Bool) -> some View {
        if thisLevel {
            Text("\(formatZoom(videoStatus.zoom))x").font(TraceFonts.body1r)
                .frame(width: 36, height: 36)
                .background(Circle().fill(.black.opacity(0.5)))
                .foregroundStyle(TraceColors.warningRegular)
                .onTapGesture {
                    withAnimation {
                        recorder.setZoom(threshold)
                    }
                }
        } else {
            Text("\(formatZoom(threshold))").font(TraceFonts.body2r)
                .frame(width: 30, height: 30)
                .background(Circle().fill(.black.opacity(0.5)))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .onTapGesture {
                    withAnimation {
                        recorder.setZoom(threshold)
                    }
                }
        }
    }
    
    func zoomButtonIdx(for val: CGFloat, in zThresholds: [CGFloat])-> Int {
        for idx in 0..<zThresholds.count {
            if val >= zThresholds[idx] &&
            (idx+1 == zThresholds.count || val < zThresholds[idx+1]) {
                return idx
            }
        }
        return 0
    }
    
    func formatZoom(_ val: CGFloat) -> String {
        let ival = Int(val * 10)
        return ival % 10 == 0 ? "\(ival/10)" : "\(Float(ival)/10.0)"
    }
}

struct AnimatingThumbView: View {
    let thumb: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
            }
            if let thumb = thumb {
                Image(thumb).resizable().scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(TraceColors.whiteNeutral2, lineWidth: 2)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 60)
                    .transition(.asymmetric(insertion: .offset(x: -88, y: 0),
                                            removal: .scale(scale: 0.5, anchor: .topLeading)
                        .combined(with: .offset(x: 15, y: -30).combined(with: .opacity))))
            }
            Spacer()
        }
    }
}
