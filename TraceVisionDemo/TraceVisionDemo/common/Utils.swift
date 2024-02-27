//
//  Utils.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/21/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import Combine
import OSLog

class ObservableWrapper<T>: ObservableObject {
    @Published
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

let alog = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "App")
