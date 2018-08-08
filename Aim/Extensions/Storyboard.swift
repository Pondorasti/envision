//
//  Storyboard.swift
//  Aim
//
//  Created by Alexandru Turcanu on 08/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    enum AIMType: String {
        case main
        case onboarding
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: AIMType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(for type: AIMType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }
        
        return initialViewController
    }
}

