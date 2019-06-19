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
    static func bullentinManager(isDismissable: Bool = false) -> BLTNItemManager {
        let manager = BLTNItemManager(rootItem: rootItem(isDismissable))
        manager.backgroundViewStyle = .blurredDark
        return manager
    }

    static func rootItem(_ isDismissable: Bool) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Envision")
        rootItem.image = UIImage(assetIdentifier: .roundedIcon)
        rootItem.descriptionText = "Create the foundation for your daily habits and improve your personal life."
        rootItem.actionButtonTitle = "Continue"

        rootItem.requiresCloseButton = isDismissable
        rootItem.isDismissable = isDismissable

        rootItem.next = holdItem(isDismissable)

        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }
        
        return rootItem
    }
    
    static func holdItem(_ isDismissable: Bool) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Completing Habits")
        rootItem.image = UIImage(assetIdentifier: .oneFingerHold)
        rootItem.descriptionText = "Hold down your finger on a bubble to complete the routine."
        rootItem.actionButtonTitle = "Next"

        rootItem.requiresCloseButton = isDismissable
        rootItem.isDismissable = isDismissable

        rootItem.next = detailItem(isDismissable)
        
        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }
        
        return rootItem
    }
    
    static func detailItem(_ isDismissable: Bool) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Looking beyond the bubbles")
        rootItem.image = UIImage(assetIdentifier: .twoFingers)
        rootItem.descriptionText = "Just tap or pinch to zoom around a bubble for more info."
        // Each habit grows if completed, your porpuse is to c
        // Each habit grows or diminishes in regard of your actions
        //
        // Ignore negative habits as they diminish / disappear into oblivion
        //                        as they grow smaller and disappear into oblivion.

        // Ignore negative habits as they diminish and disappear into oblivion.
        rootItem.actionButtonTitle = "Let's get started!"
        
        rootItem.requiresCloseButton = isDismissable
        rootItem.isDismissable = isDismissable

        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.dismissBulletin()
        }

        return rootItem
    }
}
