//
//  Color+components.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation
import SwiftUI


extension Color {

    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    
    
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255.0
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255.0
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255.0
            a = CGFloat(hexNumber & 0x000000ff) / 255.0
        }
        return (r, g, b, a)
    }
    
    func red()   -> Double { return Double(components().r) }
    func green() -> Double { return Double(components().g) }
    func blue()  -> Double { return Double(components().b) }
    func alpha() -> Double { return Double(components().a) }
}
