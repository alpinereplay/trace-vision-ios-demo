//
//  Toast.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/21/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct Toast: Equatable {
    var icon: String
    var message: String
    var duration: Double = 3
    var width: Double = .infinity
    var background = TraceColors.tealNormal10
    var foreground = TraceColors.tealNormal50
}

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if toast.icon.isNotEmpty {
                Image(systemName: toast.icon)
                    .foregroundStyle(toast.foreground)
            }
            Text(toast.message)
                .font(TraceFonts.body1r)
                .foregroundStyle(toast.foreground)
            Spacer(minLength: 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(minWidth: 0, maxWidth: toast.width)
        .background(toast.background)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ToastView(toast: Toast(icon: "checkmark", message: "This is a toast message"))
        .traceDefaults()
}

struct ToastModifier: ViewModifier {
    
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    mainToastView()
                        .offset(y: -32)
                }
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                ToastView(toast: toast)
            }.transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}
