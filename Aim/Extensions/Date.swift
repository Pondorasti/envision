//
//  Date.swift
//  Aim
//
//  Created by Alexandru Turcanu on 02/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func format(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        return dateFormatter.string(from: self)
    }
}

