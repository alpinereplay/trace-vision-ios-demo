//
//  ViewExt.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/8/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
    
    func onDeviceRotation(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
      }
}

extension View {
    func traceDefaults() -> some View {
        self
            .buttonStyle(MainButtonStyle(type: .normal))
            .environment(\.font, TraceFonts.body1r)
            .accentColor(TraceColors.tealNormal40)
            .background(TraceColors.whiteNeutral2)
            .foregroundColor(TraceColors.charcoalNeutral)
    }
    
    func onMain(_ run: @escaping ()->Void) {
        DispatchQueue.main.async(execute: run)
    }
}

extension View {
    func onSwipe(up: ((Double)->Void)? = nil,
                 down: ((Double)->Void)? = nil,
                 left: ((Double)->Void)? = nil,
                 right: ((Double)->Void)? = nil
    ) -> some View {
        self.gesture(DragGesture(minimumDistance: 4.0, coordinateSpace: .local)
            .onEnded { value in
                print(value.translation)
                switch(value.translation.width, value.translation.height) {
                case (...0, -30...30):  left?(value.translation.width)
                case (0..., -30...30):  right?(value.translation.width)
                case (-100...100, ...0):  up?(value.translation.height)
                case (-100...100, 0...):  down?(value.translation.height)
                    default:  break
                }
            })
    }
}
