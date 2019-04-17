//
//  CALayerAnimations.swift
//  Aim
//
//  Created by Alexandru Turcanu on 17/04/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

extension UIView {
    func addShakeAnimation(for duration: TimeInterval = 0.1, repeatCount: Float = 2) {
        let shakingAnimation = CABasicAnimation(keyPath: "position")

        shakingAnimation.duration = duration
        shakingAnimation.repeatCount = 2
        shakingAnimation.autoreverses = true

        shakingAnimation.fromValue = CGPoint(x: center.x - 5, y: center.y)
        shakingAnimation.toValue = CGPoint(x: center.x + 5, y: center.y)

        layer.add(shakingAnimation, forKey: "Shake \(String(describing: self))")
    }
}
