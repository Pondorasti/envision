//
//  Constants.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    struct Layer {
        static let cornerRadius: CGFloat = 10
        static let shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.18).cgColor
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowOpacity: Float = 18
        static let shadowRadius: CGFloat = 2
        static let backgroundColor: UIColor = #colorLiteral(red: 0.1568627451, green: 0.07058823529, blue: 0.2509803922, alpha: 1)
        static let habitTextColor: UIColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
    }
    
    struct Color {
        static let colorPicker = [UIEntryPickerView.Entry.major(with: UIColor.AIMRed, andPhoto: "AIMRed"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMBlue, andPhoto: "AIMBlue"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMPink, andPhoto: "AIMPink"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMLightBlue, andPhoto: "AIMLightBlue"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMDarkBlue, andPhoto: "AIMDarkBlue"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMBrown, andPhoto: "AIMBrown"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMMagenta, andPhoto: "AIMMagenta"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMGreen, andPhoto: "AIMGreen"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMBadRed, andPhoto: "AIMBadRed"),
                                  UIEntryPickerView.Entry.major(with: UIColor.AIMOrange, andPhoto: "AIMOrange"),]
    }
    
    struct Calendar {
        static let insideMonthDateColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 0.95)
        static let outsideMonthDateColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 0.5)
        
        static let outsideMonthSelectedViewColor: UIColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 0.5)
        static let insideMonthSelectedViewColor: UIColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        
        static let weekNamesColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 0.8)
        
        static let titleColor: UIColor = #colorLiteral(red: 0.01960784314, green: 0.01960784314, blue: 0.01960784314, alpha: 0.5)
        
        static let format: String = "yyyy MM dd"
    }
    
    struct StatisticsView {
        static let percentageLineWidth: CGFloat = 10
        static let percentageDiameter: CGFloat = 100
    }
    
    struct Storyboard {
        static let detailedHabit: String = "detailedHabit"
    }
    
    struct Cell {
        static let dateCell: String = "dateCell"
    }
    
    struct Segue {
        static let goBack: String = "goBack"
        static let createHabit: String = "createHabit"
        static let cancelHabit: String = "cancelHabit"
        static let actuallyCreateHabit: String = "actuallyCreateHabit"
        static let showSettings: String = "showSettings"
        static let goBackHomeFromSettings: String = "goBackHomeFromSettings"
        static let destoryHabit: String = "destoryHabit"
    }
    
    struct SpriteKit {
        static let force: CGFloat = 400
    }
    
    struct ImageName {
        static let oneFingerHold: String = "OneFingerHold"
        static let twoFingers: String = "TwoFingers"
        static let roundedIcon: String = "RoundedIcon"
    }
    
    struct UserDefaults {
        static let notFirstInApp = "notFirstInApp"
    }
}
