//
//  MainView.swift
//  TraceAction
//
//  Copyright (c) AlpineReplay 2023
//  Created by Leo Khramov on 12/6/23.
//

import Foundation
import SwiftUI
import TraceVisionSDK

/// Main view of the app
struct MainView: View {
    @ObservedObject
    var flow = NavigationFlow.shared

    @State
    var actionChooserOpened = false
    
    @State
    var showRecordPermissionAlert = false
    
    @State
    var loading = true
    
    @Namespace var cellNamespace
    
    @ObservedObject
    var sdk = TraceVision.shared
    
    @State
    var emptyText = ""
    
    var mainView: some View {
        ZStack {
            if loading {
                VStack {
                    Image("vision_logo")
                        .padding(.bottom, 50)
                    LoadingView()
                }
                .padding(50)
            } else {
                if !emptyText.isEmpty {
                    VStack {
                        Text(emptyText).font(TraceFonts.htitle4b)
                    }
                    .padding(50)
                } else {
                    HighlightsGallery()
                        .blur(radius: actionChooserOpened ? 4.0 : 0)
                    ActionButtonMenu(actionChooserOpened: $actionChooserOpened,
                                     showRecordPermissionAlert: $showRecordPermissionAlert,
                                     recordVideo: recordVideo,
                                     importVideo: importVideo,
                                     namespace: cellNamespace)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Expander()
            mainView
        }
        .ignoresSafeArea()
        // listen to SDK inited state
        .onChange(of: sdk.isSDKInited, perform: checkSDKReady)
    }
    
    /// Check if SDK is ready and set loading flag and error message accordingly
    func checkSDKReady(isReady: Bool?) {
        alog.debug("SDK inited: \(isReady == nil ? "NULL" : String(isReady!) )")
        if isReady == true {
            loading = false
        }
        if isReady == false {
            emptyText = "Error: SDK is not properly initialized.\nPlease check your internet connection and consumer key/secret pair.\nRestart the app to try again."
            loading = false
        }
    }
    
    /// Record video action. Checks permissions and navigates to the video recorder
    func recordVideo() {
        let audioP = PermissionHandler.shared.audioPermissionState()
        let videoP = PermissionHandler.shared.videoPermissionState()
        if audioP == .Denied || videoP == .Denied {
            showRecordPermissionAlert = true
            return
        }
        
        if audioP == .NeverAsked || videoP == .NeverAsked {
            PermissionHandler.shared.onDone = {
                recordVideo()
            }
            PermissionHandler.shared.askAudioPermission()
            return
        }
        
        actionChooserOpened = false
        
        if audioP == .Granted && videoP == .Granted {
            //Now we can go to recording screen
            flow.navigate(dest:
                            NavigationParams(.videoRecorder)
                .add(param: "session", value: TraceVision.shared.createVideoRecordSession(exportFullVideo: true)))
        }
    }
    
    /// Import video action with the chosed video via provider. Navigates to the video import screen
    func importVideo(provider: NSItemProvider?) {
        actionChooserOpened = false
        NavigationFlow.shared.navigate(dest:
                                        NavigationParams(.importVideoProcessor)
            .add(param: "provider", value: provider as Any)
            .add(param: "session", value: TraceVision.shared.createVideoImportSession())
        )
    }
}

#Preview {
    MainView().traceDefaults()
}

/// The ActionButtonMenu struct is a SwiftUI view designed to offer users a choice between recording a new video or uploading a video from their photos.
struct ActionButtonMenu: View {
    @Binding
    var actionChooserOpened: Bool
    
    @Binding
    var showRecordPermissionAlert: Bool
    
    /// A closure that gets called when the user decides to record a new video. This action is triggered by a button within the view.
    var recordVideo: ()->Void
    
    /// A closure that is called with an optional NSItemProvider argument when the user chooses to upload a video. This allows for the importation of video content from the user's photo library.
    var importVideo: (NSItemProvider?)->Void
        
    @State
    var isVideoPickerShown = false
    
    let namespace: Namespace.ID
    
    var body: some View {
        if actionChooserOpened {
            Color(.white)
                .opacity(0.75)
                .onTapGesture {
                withAnimation {
                    actionChooserOpened = false
                }
            }
        }
        VStack(alignment: .trailing) {
            Spacer()
            if actionChooserOpened {
                recorderButton()
                uploadButton()
            }
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        actionChooserOpened = !actionChooserOpened
                    }
                }) {
                    withAnimation {
                        Image(systemName: "plus")
                            .font(Font.system(size: 24, weight: .bold))
                            .rotationEffect(.degrees(actionChooserOpened ? -45 : 0))
                    }
                }
                .buttonStyle(MainButtonStyle(paddingSides: 64, paddingVertical: 64, circle: true))
            }
        }
        .padding(.bottom, 32).padding(.horizontal, 32)
    }
    
    /// Returns a view for the button that initiates video recording. It includes text and an icon, styled distinctly to indicate the action. This button also manages the display of an alert for permission requirements if necessary.
    func recorderButton() -> some View {
        HStack {
            Text("Record a new video").font(TraceFonts.body1r)
                .padding(6)
            Button(role: .cancel, action: {recordVideo()}) {
                Image(systemName: "video")
                    .font(Font.system(size: 24, weight: .bold))
            }.buttonStyle(MainButtonStyle(paddingSides: 64, paddingVertical: 64, circle: true, desiredBackColor: TraceColors.greenNormal1, desiredFrontColor: TraceColors.charcoalNormal50))
                .alert("Permissions required", isPresented: $showRecordPermissionAlert, actions: {
                    Button("Open Settings", role: .none) {
                        PermissionHandler.shared.openSettings()
                        showRecordPermissionAlert = false
                    }
                    Button("Cancel", role: .cancel) {
                        showRecordPermissionAlert = false
                    }
                }, message: {
                    Text("Video recorder requires access to camera and microphone. Please open Settings and grant the missing access.")
                })
        }
        .transition(.offset(x: 0, y: 124).combined(with: .opacity))
    }
    
    /// Returns a view for the button that opens the video picker for uploading a video from the user's photos. It similarly includes text and an icon, with styling that differentiates it from the recorder button. The upload action triggers the presentation of a VideoPickerView.
    func uploadButton() -> some View {
        HStack {
            Text("Upload video from photos").font(TraceFonts.body1r)
                .padding(6)
            Button(role: .none, action: {isVideoPickerShown = true}) {
                Image(systemName: "square.and.arrow.down")
                    .font(Font.system(size: 24, weight: .bold))
            }.buttonStyle(MainButtonStyle(paddingSides: 64, paddingVertical: 64, circle: true, desiredBackColor: TraceColors.blueNormal1, desiredFrontColor: TraceColors.charcoalNormal50))
                .sheet(isPresented: $isVideoPickerShown) {
                    /// Open the video picker
                    VideoPickerView() { provider in
                        isVideoPickerShown = false
                        if let provider = provider {
                            importVideo(provider)
                        }
                    }
                }
        }
        .transition(.offset(x: 0, y: 71).combined(with: .opacity))
    }
}
