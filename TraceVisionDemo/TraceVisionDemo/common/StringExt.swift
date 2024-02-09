//
// Created by Leo Khramov on 7/21/22.
// Copyright (c) 2022 AlpineReplay. All rights reserved.
//

import SwiftUI

extension String {
    /// Shuffles the contents of this collection.
    func color() -> Color {
        return Color(uiColor: uicolor())
    }

    func uicolor() -> UIColor {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String {
    private static let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
    private static let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
    private static let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,6}"
    private static let __phoneRegex = "^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$"
    public var isEmail: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type(of:self).__emailRegex)
        return predicate.evaluate(with: self)
    }

    public var isPhoneNumber: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", type(of:self).__phoneRegex)
        return predicate.evaluate(with: self)
    }

    public var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    public var isBlank: Bool {
        return isEmail || self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func toFullName() -> (firstName: String, lastName: String)? {
        let fname = trim()
        let parts = fname.split(separator: " ")
        if parts.count < 2 {
            return nil
        }
        return (String(parts[0]), parts[1..<parts.count].joined(separator: " "))
    }
}

extension String {
    func format(_ arguments: [CVarArg]) -> String {
        String(format: self, arguments: arguments)
    }
}

extension String {

    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard
                let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
                        , leftRange.upperBound <= rightRange.lowerBound
        else { return nil }

        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }

    var length: Int {
        get {
            count
        }
    }

    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }

    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }

    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }

    func character(_ at: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: at)]
    }

    func lastIndexOfCharacter(_ c: Character) -> Int? {
        guard let index = range(of: String(c), options: .backwards)?.lowerBound else
        { return nil }
        return distance(from: startIndex, to: index)
    }
}
