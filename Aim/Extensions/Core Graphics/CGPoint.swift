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
    func normalizeFromSpriteKitToUIKit(frameHeight: CGFloat) -> CGPoint {
        return CGPoint(
            x: self.x,
            y: (self.y - frameHeight) < 0 ? (self.y - frameHeight) * (-1) : (self.y - frameHeight)
        )
    }

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