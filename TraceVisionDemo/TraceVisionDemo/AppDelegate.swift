//
//  AppDelegate.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/8/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import UIKit
import TraceVisionSDK
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else if orientationLock == .portrait {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // AppDelegate.orientationLock = .portrait
        
        
        /// TraceVision SDK requires developer (consumer) key and token to work.
        /// Read the token and secret from Info.plist
        /// Put your consumer token and secret in the Info.plist file
        /// under the keys `VISION_TOKEN` and `VISION_SECRET` respectively
        var visionToken = Bundle.main.object(forInfoDictionaryKey: "VISION_TOKEN") as? String ?? "NO_TOKEN"
        var visionSecret = Bundle.main.object(forInfoDictionaryKey: "VISION_SECRET") as? String ?? "NO_SECRET"
        
        // Initialize TraceVision SDK with your token and secret
        // This should be done only once when the app is launched
        TraceVision.shared.initSDK(token: visionToken, secret: visionSecret)
        alog.debug("TraceVisionSDK token: [\(visionToken)/\(visionSecret)]")
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
