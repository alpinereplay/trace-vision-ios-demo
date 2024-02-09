//
//  DateExt.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/15/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation

extension Date {
    static var currentTimeMillis: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
