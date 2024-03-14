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


/// Set your consumer token and secret here
///
/// You can find your API token and secret in
/// the [TraceVision developer console](https://developer.tracevision.com).
let VISION_TOKEN = "PUT_YOUR_TOKEN_HERE"
let VISION_SECRET = "PUT_YOUR_SECRET_HERE"

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        /// TraceVision SDK requires developer (consumer) key and token to work.
        /// Read the token and secret from Info.plist
        /// Put your consumer token and secret in the Info.plist file
        /// under the keys `VISION_TOKEN` and `VISION_SECRET` respectively
        /// or just set them at the top of this file.
        var visionToken = VISION_TOKEN
        var visionSecret = VISION_SECRET
        
        if visionToken.starts(with: "PUT_YOUR") {
            visionToken = Bundle.main.object(forInfoDictionaryKey: "VISION_TOKEN") as? String ?? ""
            visionSecret = Bundle.main.object(forInfoDictionaryKey: "VISION_SECRET") as? String ?? ""
        }

        
        // Initialize TraceVision SDK with your token and secret
        // This should be done only once when the app is launched
        TraceVision.shared.initSDK(token: visionToken, secret: visionSecret)
        alog.debug("TraceVisionSDK token: [\(visionToken)/\(visionSecret)]")
        return true
    }    
}
