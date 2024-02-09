//
//  ImageExt.swift
//  TraceAction
//
//  Created by Leo Khramov on 1/15/24.
//  Code taken from: https://gist.github.com/karigrooms/fdf435274f4403abd57b1ed533dcea53
//

import Foundation
import SwiftUI

/// Common aspect ratios
public enum AspectRatio: CGFloat {
    case square = 1
    case threeToFour = 0.75
    case fourToThree = 1.75
}

/// Fit an image to a certain aspect ratio while maintaining its aspect ratio
public struct FitToAspectRatio: ViewModifier {
    
    private let aspectRatio: CGFloat
    
    public init(_ aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }
    
    public init(_ aspectRatio: AspectRatio) {
        self.aspectRatio = aspectRatio.rawValue
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(.clear))
                .aspectRatio(aspectRatio, contentMode: .fit)

            content
                .scaledToFill()
                .layoutPriority(-1)
        }
        .clipped()
    }
}

// Image extension that composes with the `.resizable()` modifier
public extension Image {
    func fitToAspectRatio(_ aspectRatio: CGFloat) -> some View {
        self.resizable().modifier(FitToAspectRatio(aspectRatio))
    }
    
    func fitToAspectRatio(_ aspectRatio: AspectRatio) -> some View {
        self.resizable().modifier(FitToAspectRatio(aspectRatio))
    }
}


extension Image {
    init(local: URL) {
        let data = NSData(contentsOf: local as URL)
        if let data = data, let uimg = UIImage(data: data as Data) {
            self.init(uiImage: uimg)
        } else {
            self.init(systemName: "photo")
        }
    }
}
