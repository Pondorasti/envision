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
        rootItem.descriptionText = "Each type of habit evolves and behaves according to your actions."
        rootItem.actionButtonTitle = "Continue"

        //
        // Create the foundation for your daily habits and improve your personal life.

        rootItem.requiresCloseButton = isDismissable
        rootItem.isDismissable = isDismissable

        rootItem.next = bubblesItem(isDismissable)

        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }
        
        return rootItem
    }

    static func bubblesItem(_ isDismissable: Bool) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Positive Habits")
        rootItem.image = UIImage(assetIdentifier: .goodHabit)
        rootItem.descriptionText = "Positive habits grow as you complete them, but they shrink if neglected."
        rootItem.actionButtonTitle = "Next"

        // Each habit grows if completed, your porpuse is to c
        // Each habit grows or diminishes in regard of your actions
        // Each habit grows if completed and shrinks if ignored.

        rootItem.requiresCloseButton = isDismissable
        rootItem.isDismissable = isDismissable

        rootItem.next = negativeHabitItem(isDismissable)

        rootItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            item.manager?.displayNextItem()
        }

        return rootItem
    }

    static func negativeHabitItem(_ isDismissable: Bool) -> BLTNPageItem {
        let rootItem = BLTNPageItem(title: "Negative Habits")
        rootItem.image = UIImage(assetIdentifier: .badHabit)
        rootItem.descriptionText = "Ignore negative habits as they grow smaller and disapper into oblivion."
        rootItem.actionButtonTitle = "Next"
        // Negative habits diminish as you stop doing them.
        // Ignore negative habits as they diminish / disappear into oblivion
        //                        as they grow smaller and disappear into oblivion.

        // Ignore negative habits as they diminish and disappear into oblivion.

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
