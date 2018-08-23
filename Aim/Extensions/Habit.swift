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
    
    var calendar: Calendar { return Calendar.current }
    
    func retrieveCompletedDays() -> [String: Bool] {
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
        var currentDate: Date = Date()
        
        var stringCreationDate = creationDate.format(with: Constant.Calendar.format)
        var stringNextDate: String {
            return currentDate.format(with: Constant.Calendar.format)
        }
        
        let completedDays = self.retrieveCompletedDays()
        var ans = 0
        
        repeat {
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                return ans
            }
            
            let stringCurrentDate = currentDate.format(with: Constant.Calendar.format)
            currentDate = nextDate
            
            if let state = completedDays[stringCurrentDate], state == isGood {
                ans += 1
            } else if completedDays[stringCurrentDate] == nil, !isGood {
                ans += 1
            } else {
                if stringCurrentDate != Date().format(with: Constant.Calendar.format) {
                    break
                }
            }
            
        } while stringCreationDate <= stringNextDate
        
        return ans
    }
    
    var iteration: Int {
        let endDate = Date()
        let completedDays = self.retrieveCompletedDays()

        var startDate = self.creationDate
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
    
    func wasCompleted(for date: Date) -> Bool {
        let stringFormat = date.format(with: Constant.Calendar.format)
        let completedDays = self.retrieveCompletedDays()
        
        if let state = completedDays[stringFormat], state == true {
            return true
        } else {
            return false
        }
    }
    
    func removeLog(for dateToRemove: String) {
        guard let arrayOfLogs = logs?.allObjects as? [Log] else { return }
        
        for log in arrayOfLogs {
            let logStringFormat = log.day.format(with: Constant.Calendar.format)
            if dateToRemove == logStringFormat {
                CoreDataHelper.deletedLog(log)
                return
            }
        }
    }
    
    func createLog(for dateToAdd: Date) {
        let newLog = CoreDataHelper.newLog()
        newLog.day = dateToAdd
        CoreDataHelper.linkLog(newLog, to: self)
    }
    
    var percentage: Double {
        let endDate = Date()
        let completedDays = self.retrieveCompletedDays()
        
        var startDate = self.creationDate
        var completions: Double = 0
        var totalNumber: Double = 0
        
        while startDate <= endDate {
            
            let stringFormat = startDate.format(with: Constant.Calendar.format)
            if let state = completedDays[stringFormat], state == true {
                completions += 1
            }
            totalNumber += 1
            
            
            if let date = calendar.date(byAdding: .day, value: 1, to: startDate) {
                startDate = date
            } else {
                return completions / totalNumber
            }
        }
        

        return completions / totalNumber
    }
}
