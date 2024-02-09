//
//  ColorExt.swift
//  TraceAction
//
//  Created by Leo Khramov on 12/14/23.
//  Copyright © 2023 AlpineReplay, Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}

extension Color {
    func lighter(componentDelta: CGFloat = 0.1) -> Color {
        let ucolor = UIColor(self)
        return Color(uiColor: ucolor.lighter(componentDelta: componentDelta))
    }

    func darker(componentDelta: CGFloat = 0.1) -> Color {
        let ucolor = UIColor(self)
        return Color(uiColor: ucolor.darker(componentDelta: componentDelta))
    }
}
