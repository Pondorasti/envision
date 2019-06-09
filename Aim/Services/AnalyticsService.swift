//
//  AnalyticsService.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
//import FirebaseAnalytics

struct AnalyticsService {
    
    static func logNewHabit(_ habit: Habit) {
//        Analytics.logEvent("newHabit", parameters: ["habitName": habit.name,
//                                                    "habitType": habit.isGood])
    }
    
    static func logUpdatedHabits(_ habits: [Habit]) {
        for habit in habits {
            let streakInfo = habit.retrieveStreakInfo()
            let completionInfo = habit.retrieveCompletionInfo()
//            Analytics.logEvent("habitInfo", parameters: ["habitName": habit.name,
//                                                        "habitType": habit.isGood,
//                                                        "currentStreak": streakInfo.current,
//                                                        "bestStreak": streakInfo.best,
//                                                        "numberOfCompletionDays": completionInfo.numberOfCompletions,
//                                                        "numberOfHabitDays": completionInfo.numberOfHabitDays])
        }
    }
    
    static func logDeletedHabit(_ habit: Habit) {
//        Analytics.logEvent("habitDeleted", parameters: ["habitName": habit.name])
    }
}
