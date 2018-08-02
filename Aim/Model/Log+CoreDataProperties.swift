//
//  Log+CoreDataProperties.swift
//  Aim
//
//  Created by Alexandru Turcanu on 01/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Logs")
    }

    @NSManaged public var day: Date
    @NSManaged public var habit: Habit

}
