//
//  OnboardindViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 07/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import BLTNBoard

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
            self.dismissScreen()
        }
        
        bulletinManager.allowsSwipeInteraction = false
        bulletinManager.showBulletin(above: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.07058823529, blue: 0.2509803922, alpha: 1)

        // Do any additional setup after loading the view.
    }
    
    private func dismissScreen() {
        let mainVC = UIStoryboard.initialViewController(for: .main)
        
        dismiss(animated: true) {
            self.view.window?.rootViewController = mainVC
            self.view.window?.makeKeyAndVisible()
        }
    }
}
