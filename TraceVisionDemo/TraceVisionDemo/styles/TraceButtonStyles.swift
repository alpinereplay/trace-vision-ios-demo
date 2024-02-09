//
//  TraceButtonStyles.swift
//  TraceAction
//
//  Copyright (c) AlpineReplay 2023
//  Created by Leo Khramov on 12/6/23.
//

import Foundation
import SwiftUI

enum TraceButtonType {
    case normal
    case small
}

struct MainButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var type: TraceButtonType = .normal
    
    var paddingSides:CGFloat = 30
    var paddingVertical:CGFloat = 18
    
    var circle = false
    
    var desiredBackColor:Color? = nil
    var desiredFrontColor:Color? = nil
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let backColor = butBackground(configuration: configuration)
        let foreColor = butForeground(configuration: configuration)
        let labelFont: Font = type == .normal ? TraceFonts.button1 : TraceFonts.button2
        
        if circle {
             HStack {
                Spacer()
                configuration.label
                Spacer()
            }
            .frame(width: paddingSides, height: paddingVertical)
            .foregroundColor(foreColor)
            .background(Circle().fill(backColor))
            .clipShape(Circle())
            .saturation(isEnabled ? 1 : 0)
        } else {            
            HStack {
                Spacer()
                configuration.label
                Spacer()
            }
            .padding(EdgeInsets(top: paddingVertical, leading: paddingSides, bottom: paddingVertical, trailing: paddingSides))
            .foregroundColor(foreColor)
            .font(labelFont)
            .background {
                Capsule()
                    .fill(backColor)
            }
            .saturation(isEnabled ? 1 : 0)
        }
    }
}

extension MainButtonStyle {
    public func butForeground(configuration: Self.Configuration) -> Color {
        var foreColor: Color
        if let color = desiredFrontColor {
            foreColor = configuration.isPressed ? color.darker(componentDelta: 0.1) : color
        } else {
            switch configuration.role {
            case ButtonRole.cancel:
                foreColor = TraceColors.tealNormal40
            case ButtonRole.destructive:
                foreColor = TraceColors.whiteNeutral2
            default:
                foreColor = TraceColors.whiteNeutral2
            }
            
            if configuration.isPressed {
                switch configuration.role {
                case ButtonRole.cancel:
                    foreColor = TraceColors.tealNormal40
                case ButtonRole.destructive:
                    foreColor = TraceColors.whiteNeutral2
                default:
                    foreColor = TraceColors.whiteNeutral2
                }
            }
        }
        return foreColor
    }

    public func butBackground(configuration: Self.Configuration) -> Color {
        var backColor: Color
        if let color = desiredBackColor {
            backColor = configuration.isPressed ? color.darker(componentDelta: 0.1) : color
        } else {
            switch configuration.role {
            case ButtonRole.cancel:
                backColor = TraceColors.tealNormal20
            case ButtonRole.destructive:
                backColor = TraceColors.errorRegular
            default:
                backColor = TraceColors.tealReleased40
            }
            
            if configuration.isPressed {
                switch configuration.role {
                case ButtonRole.cancel:
                    backColor = TraceColors.tealNormal10
                case ButtonRole.destructive:
                    backColor = TraceColors.errorTint1
                default:
                    backColor = TraceColors.tealPressed40
                }
            }
        }
        return backColor
    }
}

struct ImageButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    var wSize:CGFloat = 40
    var hSize:CGFloat = 40
    
    var circle = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.saturation(configuration.isPressed ? 0.7 : 1)
            Spacer()
        }
        .frame(width: wSize, height: hSize)
        .foregroundColor(.black.opacity(0))
        .background(.black.opacity(0))
        .saturation(isEnabled ? 1 : 0.3)
    }
}

struct MakeSquareBounds: ViewModifier {

    @State var size: CGFloat = 1000
    func body(content: Content) -> some View {
        let c = ZStack {
            content.alignmentGuide(HorizontalAlignment.center) { (vd) -> CGFloat in
                DispatchQueue.main.async {
                    self.size = max(vd.height, vd.width)
                }
                return vd[HorizontalAlignment.center]
            }
        }
        return c.frame(width: size, height: size)
    }
}


