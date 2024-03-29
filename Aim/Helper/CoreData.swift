//
//  CoreData.swift
//  Aim
//
//  Created by Alexandru Turcanu on 26/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        return context
    }()
    
    static func newHabit() -> Habit {
        let habit = NSEntityDescription.insertNewObject(forEntityName: "Habits", into: context) as! Habit
        return habit
    }
    
    static func newLog() -> Log {
        let log = NSEntityDescription.insertNewObject(forEntityName: "Logs", into: context) as! Log
        return log
    }
    
    static func saveHabit() {
        do {
            try context.save()
        } catch let error {
            assertionFailure("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        saveHabit()
    }
    
    static func deletedLog(_ log: Log) {
        context.delete(log)
        saveHabit()
    }
    
    static func retrieveHabits() -> [Habit] {
        do {
            let fetchRequest = NSFetchRequest<Habit>(entityName: "Habits")
            let results = try context.fetch(fetchRequest)
            
            return results
        } catch let error {
            assertionFailure("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
    
    static func linkLog(_ log: Log, to habit: Habit) {
        habit.addToLogs(log)
        saveHabit()
    }
}
