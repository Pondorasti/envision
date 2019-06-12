//
//  CGRect.swift
//  Aim
//
//  Created by Alexandru Turcanu on 12/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

extension CGRect {
    func increase(byPercentage percentage: CGFloat) -> CGRect {
        let startWidth = self.width
        let startHeight = self.height
        let adjustmentWidth = (startWidth * percentage) / 2.0
        let adjustmentHeight = (startHeight * percentage) / 2.0

        return self.insetBy(dx: -adjustmentWidth, dy: -adjustmentHeight)
    }
}
