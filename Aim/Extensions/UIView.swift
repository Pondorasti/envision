//
//  UIView.swift
//  Aim
//
//  Created by Alexandru Turcanu on 26/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func configure(with color: UIColor) {
        layer.cornerRadius = Constant.Layer.cornerRadius
        layer.shadowColor = Constant.Layer.shadowColor
        layer.shadowOffset = Constant.Layer.shadowOffset
        layer.shadowOpacity = Constant.Layer.shadowOpacity
        layer.shadowRadius = Constant.Layer.shadowRadius
        layer.masksToBounds = false
        backgroundColor = color
    }
}
