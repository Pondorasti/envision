//
//  Int.swift
//  Aim
//
//  Created by Alexandru Turcanu on 12/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import Foundation

extension Int {
    static func randomNumber(inRange range: CountableClosedRange<Int>) -> Int {
        let length = Int(range.upperBound - range.lowerBound + 1)
        let value = Int(arc4random()) % length + Int(range.lowerBound)
        return value
    }
}
