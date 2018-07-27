//
//  UIColor.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let AIMGreen = #colorLiteral(red: 0.4431372549, green: 0.968627451, blue: 0.6235294118, alpha: 1)
    static let AIMDarkBlue = #colorLiteral(red: 0.2039215686, green: 0.3490196078, blue: 0.5843137255, alpha: 1)
    static let AIMBlue = #colorLiteral(red: 0.2823529412, green: 0.6745098039, blue: 0.9411764706, alpha: 1)
    static let AIMLightBlue = #colorLiteral(red: 0, green: 0.8039215686, blue: 0.7764705882, alpha: 1)
    static let AIMPink = #colorLiteral(red: 1, green: 0.5176470588, blue: 0.9098039216, alpha: 1)
    static let AIMOrange = #colorLiteral(red: 1, green: 0.5333333333, blue: 0.06666666667, alpha: 1)
    static let AIMMagenta = #colorLiteral(red: 0.6470588235, green: 0.2745098039, blue: 0.3411764706, alpha: 1)
    static let AIMBadRed = #colorLiteral(red: 0.937254902, green: 0.462745098, blue: 0.4549019608, alpha: 1)
    static let AIMBrown = #colorLiteral(red: 0.8705882353, green: 0.7960784314, blue: 0.7176470588, alpha: 1)
    static let AIMRed = #colorLiteral(red: 0.9529411765, green: 0.1411764706, blue: 0.4431372549, alpha: 1)

    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count
        
        Scanner(string: hexNormalized).scanHexInt32(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var hex: String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        
        return hex
    }
}
