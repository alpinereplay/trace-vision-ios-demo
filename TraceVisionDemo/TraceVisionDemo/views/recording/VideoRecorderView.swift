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
    
    /// The session for video recording
    ///
    /// Should be passed as a parameter to the view. Need to be created just once even if the view is recreated due to other value changes
    let session: VideoRecordSessionProtocol
    
    /// The preview layer for the camera. 
    ///
    /// We set it in on `appear()` after the camera is initialized
    @State
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    /// Observe the processing/recording status via this status object
    ///
    /// We connect it to the actual session in `appear()` when we initialize our session
    @StateObject
    var videoStatus: VideoRecorderStatus = VideoRecorderStatus()
    
    @State
    var isTransitioning: Bool = false
    
    @State
    var currentMagnification: CGFloat = 0
    
    @State
    var initialZoom: CGFloat = 0
    
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
                                        initialZoom = session.userFacingZoom
                                    }
                                    session.setZoom(initialZoom * ((delta - 1) * 0.7 + 1))
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
                                HighlightCountView(count: videoStatus.highlightsFound).padding(.leading, 24)
                            }
                            Spacer()
                            if videoStatus.processing != true {
                                Button(action: {
                                    stopCamera()
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
                            Spacer()
                        }
                    }.padding(.top, isVertical ? 0 : 20)
                    Spacer()
                }
                if isVertical {
                    VStack {
                        Spacer()
                        ZoomControlsView(recorder: session, videoStatus: videoStatus, isVertical: true)
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
                        ZoomControlsView(recorder: session, videoStatus: videoStatus, isVertical: false)
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
            }
            .background(TraceColors.charcoalNormal50)
            .forceRotation(orientation: .allButUpsideDown)
            .onAppear() {
                startCamera()
            }
            .onDisappear() {
                stopCamera()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    alog.debug("Active")
                } else if newPhase == .inactive {
                    alog.debug("Inactive")
                } else if newPhase == .background {
                    alog.debug("Background")
                    session.stopRecording()
                }
            }
            .onChange(of: videoStatus.processing) { val in
                isTransitioning = false
            }
            .onChange(of: videoStatus.isInitialized) { val in
                isTransitioning = !val
            }
            .onDeviceRotation { orientation in
                session.changeVideoOrientation(device2cameraOrientation(orientation))
            }
            .toast($toast)
            .toolbar(.hidden)
        }
    }
    
    /// Setup the camera, initialize it and get the preview layer
    ///
    /// Session will initialize the camera and start providing the live preview.
    /// Actual recording won't start until `VideoRecordSessionProtocol.startRecording()` is called.
    func startCamera() {
        let recorder = session
        // we set our own copy of the status object here to have direct updates from the session
        recorder.setStatusObject(videoStatus)
        recorder.initVideoRecorder(orientation: device2cameraOrientation(UIDevice.current.orientation))
        previewLayer = recorder.previewLayer
    }
    
    /// Completely stop using the camera, no more preview, all resources are freed.
    ///
    /// If this is called during active recordingthen it will first stop the recording and then shut the camera down.
    func stopCamera() {
        session.stopVideoRecorder()
    }
    
    /// Toggle the actual recording on or off
    func toggleRecording() {
        isTransitioning = true
        if videoStatus.processing == true {
            // Stop the video recording.
            // Observe `videoStatus.processing` to become `false`
            // then you'll know that it's fully stopped.
            session.stopRecording()
            if videoStatus.highlightsFound > 0 {
                toast = Toast(icon: "checkmark", message: "\(videoStatus.highlightsFound) highlight\(videoStatus.highlightsFound > 1 ? "s" : "") created from recording")
            }
        } else {
            // Start the video recording and highlights detection on the fly.
            session.startRecording()
        }
    }
    
    func device2cameraOrientation(_ orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
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
        return videoO
    }
}

#Preview {
    VideoRecorderView(session: TraceVision.shared.createVideoRecordSession()).traceDefaults()
}

struct HighlightCountView: View {
    let count: Int
    
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
        .padding(6)
        .background(Color.black.opacity(0.4))
        .cornerRadius(4)
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

