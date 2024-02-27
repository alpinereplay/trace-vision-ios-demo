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

struct ActionButtonMenu: View {
    @Binding
    var actionChooserOpened: Bool
    
    @Binding
    var showRecordPermissionAlert: Bool
    
    var recordVideo: ()->Void
    
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
            HStack {
                Spacer()
            }
            Spacer()
            if actionChooserOpened {
                recorderButton()
                uploadButton()
            }
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
            .matchedGeometryEffect(id: "button", in: namespace)
        }
        .padding(.bottom, 32).padding(.horizontal, 32)
    }
    
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
    
    func uploadButton() -> some View {
        HStack {
            Text("Upload video from photos").font(TraceFonts.body1r)
                .padding(6)
            Button(role: .none, action: {isVideoPickerShown = true}) {
                Image(systemName: "square.and.arrow.down")
                    .font(Font.system(size: 24, weight: .bold))
            }.buttonStyle(MainButtonStyle(paddingSides: 64, paddingVertical: 64, circle: true, desiredBackColor: TraceColors.blueNormal1, desiredFrontColor: TraceColors.charcoalNormal50))
                .sheet(isPresented: $isVideoPickerShown) {
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

struct MainView: View {
    @ObservedObject
    var flow = NavigationFlow.shared

    @State
    var actionChooserOpened = false
    
    @State
    var showRecordPermissionAlert = false
    
    @State
    var items = [HighlightObject]()
    
    @State
    var selectedIdx: Int?
    
    @State
    var loading = true
    
    @Namespace var cellNamespace
    
    @ObservedObject
    var sdk = TraceVision.shared
    
    @State
    var emptyText = "No highlights detected.\nPlease click '+' button to start your journey."
    
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
                if items.isEmpty {
                    VStack {
                        Text(emptyText).font(TraceFonts.htitle4b)
                    }
                    .padding(50)
                } else {
                    GalleryView(items: items, selectedItemIdx: $selectedIdx)
                        .blur(radius: actionChooserOpened ? 4.0 : 0)
                }
            }
            if sdk.isSDKInited == true && !loading {
                ActionButtonMenu(actionChooserOpened: $actionChooserOpened,
                                 showRecordPermissionAlert: $showRecordPermissionAlert,
                                 recordVideo: recordVideo,
                                 importVideo: importVideo,
                                 namespace: cellNamespace)
            }
        }
        .task {
            await loadHighlights()
        }
    }
    
    var body: some View {
        ZStack {
            Expander()
            mainView
        }
        .ignoresSafeArea()
        .onAppear {
            selectedIdx = nil
        }
        .onChange(of: sdk.isSDKInited, perform: checkSDKReady)
        .onChange(of: selectedIdx) { idx in
            if let idx = idx, !items.isEmpty {
                NavigationFlow.shared.navigate(dest:
                                                NavigationParams(.videoPlayer)
                    .add(param: "items", value: items)
                    .add(param: "index", value: idx))
            }
        }
    }
    
    func checkSDKReady(isReady: Bool?) {
        alog.debug("SDK inited: \(isReady == nil ? "NULL" : String(isReady!) )")
        if isReady == true {
            Task {
                await loadHighlights()
            }
        }
        if isReady == false {
            withAnimation {
                items = []
                emptyText = "Error: SDK is not properly initialized.\nPlease check your internet connection and consumer key/secret pair.\nRestart the app to try again."
                loading = false
            }
        }
    }
    
    func loadHighlights() async {
        if TraceVision.shared.isSDKInited == true {
            items = await TraceVision.shared.getHighlightReader().highlightsByGroup("--")
            withAnimation {
                loading = false
            }
        }
    }
    
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
