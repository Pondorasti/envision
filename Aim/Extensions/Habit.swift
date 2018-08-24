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
    
    func retrieveStreakInfo(from _dataSet: [String: Bool]! = nil) -> (current: Int, best: Int) {
        let dataSet = (_dataSet != nil) ? _dataSet! : retrieveCompletedDays()
        
        var isFirstStreak = true
        var bestStreak = 0
        var currentStreak = 0
        var currentAns = 0 {
            didSet {
                bestStreak = currentAns > bestStreak ? currentAns : bestStreak
            }
        }
        
        var currentDate: Date = Date()
        var stringCreationDate = creationDate.format(with: Constant.Calendar.format)
        var stringNextDate: String {
            return currentDate.format(with: Constant.Calendar.format)
        }
        
        repeat {
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                return (currentStreak, bestStreak)
            }
            
            let stringCurrentDate = currentDate.format(with: Constant.Calendar.format)
            currentDate = nextDate
            
            if let state = dataSet[stringCurrentDate], state == isGood {
                currentAns += 1
            } else if dataSet[stringCurrentDate] == nil, !isGood {
                currentAns += 1
            } else {
                if stringCurrentDate != Date().format(with: Constant.Calendar.format) {
                    if isFirstStreak {
                        currentStreak = currentAns
                    }
                    
                    currentAns = 0
                }
            }
            
        } while stringCreationDate <= stringNextDate
        if isFirstStreak {
            currentStreak = currentAns
        }

        return (currentStreak, bestStreak)
    }
    
    var iteration: Int {
        let completionInfo = retrieveCompletionInfo()
        let habitIteration = completionInfo.numberOfCompletions < 50 ? completionInfo.numberOfCompletions : 50
        
        if !isGood {
            return Int((50 - habitIteration) * 0.6)
        }
        return Int(habitIteration)
    }
    
    func wasCompleted(for date: Date, in _dataSet: [String: Bool]! = nil) -> Bool {
        let dataSet = (_dataSet != nil) ? _dataSet! : retrieveCompletedDays()
        let stringFormat = date.format(with: Constant.Calendar.format)
        
        if let state = dataSet[stringFormat], state == true {
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
    
    func retrieveCompletionInfo(from _dataSet: [String: Bool]! = nil) -> (numberOfCompletions: Double, numberOfHabitDays: Double) {
        let dataSet = (_dataSet != nil) ? _dataSet! : retrieveCompletedDays()
        
        var numberOfCompletions: Double = 0
        var numberOfHabitDays: Double = 0
        
        var currentDate: Date = Date()
        var stringCreationDate = creationDate.format(with: Constant.Calendar.format)
        var stringNextDate: String {
            return currentDate.format(with: Constant.Calendar.format)
        }
        
        repeat {
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                return (numberOfCompletions, numberOfHabitDays)
            }
            
            let stringCurrentDate = currentDate.format(with: Constant.Calendar.format)
            currentDate = nextDate
            
            numberOfHabitDays += 1
            if let state = dataSet[stringCurrentDate], state == isGood {
                numberOfCompletions += 1
            } else if dataSet[stringCurrentDate] == nil, !isGood {
                numberOfCompletions += 1
            }

        } while stringCreationDate <= stringNextDate
        
        return (numberOfCompletions, numberOfHabitDays)
    }
    
}
