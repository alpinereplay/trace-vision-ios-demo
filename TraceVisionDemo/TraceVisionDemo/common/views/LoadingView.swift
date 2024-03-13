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
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(2, anchor: .center)
        }
        .padding(24)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
    }
}
