//
//  UIImage.swift
//  Aim
//
//  Created by Alexandru Turcanu on 16/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit.UIImage

extension UIImage {
    enum AssetIdentifier: String {
        case oneFingerHold = "OneFingerHold"
        case twoFingers = "TwoFingers"
        case roundedIcon = "RoundedIcon"
        case trashCan = "TrashCan"
        case chevron = "Chevron"

        case info = "Info"
        case book = "Book"
        case man = "Man"
        case star = "Star"
    }

    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}