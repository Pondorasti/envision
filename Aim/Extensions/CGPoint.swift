//
//  CGPoint.swift
//  Aim
//
//  Created by Alexandru Turcanu on 26/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    static func randomPoint(inXRange xRange: CountableClosedRange<Int>, andYRange yRange: CountableClosedRange<Int>) -> CGPoint {
        let x = CGFloat(Int.randomNumber(inRange: xRange))
        let y = CGFloat(Int.randomNumber(inRange: yRange))
        
        return CGPoint(x: x, y: y)
    }

}

extension Int {
    static func randomNumber(inRange range: CountableClosedRange<Int>) -> Int {
        let length = Int(range.upperBound - range.lowerBound + 1)
        let value = Int(arc4random()) % length + Int(range.lowerBound)
        return value
    }
}

extension String {
    func containsIllegalCharacters() -> Bool {
        
        let illegalCharacters = "()-+{}[]|"
        //()-+/\{}[]|
        for char in illegalCharacters {
            if self.contains(char) {
                return false
            }
        }
        
        if self.contains("/") {
            return false
        }
        
        if self.contains("\"") {
            return false
        }
    
        return true
    }
}




