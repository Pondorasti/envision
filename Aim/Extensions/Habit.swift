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
    
    var completedDays: [String: Bool] {
        var ans = [String: Bool]()
        if let logs = self.logs?.allObjects as? [Log] {
            for log in logs {
                let stringFormat = log.day.format(with: Constant.Calendar.format)
                ans[stringFormat] = true
            }
        }
        return ans
    }
    
    
    
    var streak: Int {
        let calendar = Calendar.current
        
        var startDate = Date()
        var endDate = self.creationDate
        var ans = 0
        
        while startDate >= endDate {
            if let date = calendar.date(byAdding: .day, value: -1, to: startDate) {
                startDate = date
                let stringFormat = startDate.format(with: Constant.Calendar.format)
                if let state = completedDays[stringFormat], state == true {
                    ans += 1
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        let stringFormat = Date().format(with: Constant.Calendar.format)
        if let state = completedDays[stringFormat], state == true {
            ans += 1
        }
        return ans
    }
    
    var iteration: Int {
        let calendar = Calendar.current
        var startDate = self.creationDate
        let endDate = Date()

        var ans = 0
        
        while startDate <= endDate {
            
            let stringFormat = startDate.format(with: Constant.Calendar.format)
            if let state = completedDays[stringFormat], state == true {
                ans += 1
            } else {
                ans -= 1
            }
            
            
            if let date = calendar.date(byAdding: .day, value: 1, to: startDate) {
                startDate = date
            } else {
                if ans < 0 { ans = 0 }
                if ans > 50 { ans = 50 }
                return ans
            }
        }
        
        if ans < 0 { ans = 0 }
        if ans > 50 { ans = 50 }
        return ans
    }
    
    var isDoneToday: Bool {
        let stringFormat = Date().format(with: Constant.Calendar.format)
        if let state = completedDays[stringFormat], state == true {
            return true
        } else {
            return false
        }
    }
}
