//
//  UINavigationBar.swift
//  Aim
//
//  Created by Alexandru Turcanu on 11/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func removeBackround() {
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.tintColor = UIColor.white
    }
}
