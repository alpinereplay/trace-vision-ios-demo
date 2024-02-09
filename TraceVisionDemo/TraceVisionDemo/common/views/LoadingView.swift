//
//  LoadingView.swift
//  TraceAction
//
//  Created by Leo Khramov on 1/18/24.
//  Copyright © 2024 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(2, anchor: .center)
    }
}
