//
//  PermissionHandler.swift
//
//  Created by Leo Khramov on 20/04/2018.
//  Copyright © 2018 TraceUp. All rights reserved.
//

import Foundation
import AVFoundation
import UserNotifications
import UIKit

class PermissionHandler {
    static let shared = PermissionHandler()
    
    enum PermissionState {
        case NeverAsked
        case Denied
        case Granted
    }
    
    var onDone: (()->Void)?
        
    func audioPermissionState() ->PermissionState {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            return .Granted
        case AVAudioSession.RecordPermission.undetermined:
            return .NeverAsked
        default:
            return .Denied
        }
    }
    
    func videoPermissionState() -> PermissionState {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            return .NeverAsked
        case .authorized:
            return .Granted
        default:
            return .Denied
        }
    }
        
    func askAudioPermission() {
        let session = AVAudioSession.sharedInstance()
        if session.recordPermission == .undetermined {
            session.requestRecordPermission({answer in
                DispatchQueue.main.async {
                    self.askVideoCapturePermission()
                }
            })
        } else {
            askVideoCapturePermission()
        }
    }

    func askVideoCapturePermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.askNotificationPermission()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    self.askNotificationPermission()
                }
            })
        }
    }

    func askNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                    (granted, error) in
                    DispatchQueue.main.async {
                        self.doneWithPermissions()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.doneWithPermissions()
                }
            }
        }
    }
    
    private func doneWithPermissions() {
        alog.debug("Done granting permissions, call delegate")
        onDone?()
        onDone = nil
    }
    
    func askAllPermissions() {
        askAudioPermission()
    }
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
}
