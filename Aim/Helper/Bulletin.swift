//
//  Bulleting.swift
//  Aim
//
//  Created by Alexandru Turcanu on 07/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import BLTNBoard
import UIKit
import TapticEngine

struct BulletinHelper {
    static func rootItem() -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Envision")
        rootItem.image = UIImage(named: Constant.ImageName.roundedIcon)
        rootItem.descriptionText = "Create the foundation for your daily habits and improve your personal life."
        rootItem.actionButtonTitle = "Continue"
        
        rootItem.requiresCloseButton = false
        rootItem.isDismissable = false
        
        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }
        
        return rootItem
    }
    
    static func holdItem() -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Completing Habits")
        rootItem.image = UIImage(named: Constant.ImageName.oneFingerHold)
        rootItem.descriptionText = "Hold down your finger on a bubble to complete the routine."
        rootItem.actionButtonTitle = "Next"
        
        rootItem.requiresCloseButton = false
        rootItem.isDismissable = false
        
        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }
        
        return rootItem
    }
    
    static func detailItem() -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Looking beyond the bubbles")
        rootItem.image = UIImage(named: Constant.ImageName.twoFingers)
        rootItem.descriptionText = "Pinch to zoom around a bubble for more info."

        rootItem.actionButtonTitle = "Let's get started!"
        
        rootItem.requiresCloseButton = false
        rootItem.isDismissable = false

        return rootItem
    }
}
