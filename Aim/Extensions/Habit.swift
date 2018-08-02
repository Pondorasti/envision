//
//  Habit.swift
//  Aim
//
//  Created by Alexandru Turcanu on 26/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

struct CalendarDate {
    let day: Int
    let month: Int
    let year: Int
    
    init(from date: Date) {
        //DateCompoents Class
        
        fatalError()
    }
}

extension Habit {
    var color: UIColor {
        get {
            guard let colorFromHex = UIColor(hex: colorInHex) else { fatalError() }
            
            return colorFromHex
        }
        set(newColor) {
            guard let hex = newColor.hex else { fatalError() }
            
            colorInHex = hex
        }
    }
//    
//    var completedDays: [CalendarDate: Bool] {
//        fatalError()
//    }

}
