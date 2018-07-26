//
//  UIButton.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func configure(with color: UIColor, andTitle title: String) {
        layer.cornerRadius = Constant.Layer.cornerRadius
        layer.shadowColor = Constant.Layer.shadowColor
        layer.shadowOffset = Constant.Layer.shadowOffset
        layer.shadowOpacity = Constant.Layer.shadowOpacity
        layer.shadowRadius = Constant.Layer.shadowRadius
        layer.masksToBounds = false
        backgroundColor = color
        
        setTitle(title, for: .normal)
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    }
}
