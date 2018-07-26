//
//  Habit.swift
//  Aim
//
//  Created by Alexandru Turcanu on 26/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension Habit {
    var color: UIColor? {
        get {
            guard let hex = colorInHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                colorInHex = newColor.hex
            }
        }
    }

}
