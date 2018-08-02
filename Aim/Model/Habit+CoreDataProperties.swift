//
//  Habit+CoreDataProperties.swift
//  Aim
//
//  Created by Alexandru Turcanu on 01/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habits")
    }

    @NSManaged public var colorInHex: String
    @NSManaged public var creationDate: Date
    @NSManaged public var isGood: Bool
    @NSManaged public var iteration: Int16
    @NSManaged public var name: String
    @NSManaged public var logs: NSSet?

}

// MARK: Generated accessors for logs
extension Habit {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: Log)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: Log)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: NSSet)

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: NSSet)

}
