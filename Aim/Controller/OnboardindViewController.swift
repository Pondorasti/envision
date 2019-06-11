//
//  OnboardindViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 07/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import BLTNBoard
import TapticEngine

class OnboardindViewController: UIViewController {
    
    let holdItem = BulletinHelper.holdItem()
    let detailItem = BulletinHelper.detailItem()
    
    lazy var bulletinManager: BLTNItemManager = {
        let rootItem = BulletinHelper.rootItem()
        rootItem.next = holdItem
        
        return BLTNItemManager(rootItem: rootItem)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        holdItem.next = detailItem
        
        detailItem.actionHandler = { item in
            TapticEngine.selection.feedback()
            self.dismissScreen()
        }
        
        bulletinManager.allowsSwipeInteraction = false
        bulletinManager.showBulletin(above: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constant.Layer.backgroundColor
    }
    
    private func dismissScreen() {        
        dismiss(animated: true) {
            self.dismiss(animated: true)
        }
    }
}
