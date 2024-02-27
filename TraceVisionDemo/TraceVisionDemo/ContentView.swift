//
//  ContentView.swift
//  TraceVisionDemo
//
//  Created by Leo Khramov on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainNavigationView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .traceDefaults()
    }
}

#Preview {
    ContentView()
}
