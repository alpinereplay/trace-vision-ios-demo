//
//  NavigationFlow.swift
//  TraceAction
//
//  Copyright (c) AlpineReplay 2023
//  Created by Leo Khramov on 12/6/23.
//

import Foundation
import SwiftUI

enum NavigationDest {
    case main
    case videoRecorder
    case importVideoProcessor
    case videoPlayer
}

class NavigationParams: Hashable {
    static func == (lhs: NavigationParams, rhs: NavigationParams) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    let dest: NavigationDest
    var params: [String: Any] = [:]
    
    init(_ dest: NavigationDest) {
        self.dest = dest
    }
    
    func add(param: String, value: Any)-> NavigationParams {
        params[param] = value
        return self
    }
}

class NavigationFlow: ObservableObject {
    static let shared = NavigationFlow()
    
    @Published
    var path = NavigationPath()
        
    func clear() {
        path = .init()
    }
    
    func backToRoot() {
        path.removeLast(path.count)
    }
    
    func backToPrevious(steps: Int = 1) {
        path.removeLast(steps)
    }
    
    func navigate(dest: NavigationDest) {
        path.append(NavigationParams(dest))
    }
    
    func navigate(dest: NavigationParams) {
        path.append(dest)
    }
    
    func setTop(dest: NavigationDest) {
        clear()
        navigate(dest: dest)
    }
}
