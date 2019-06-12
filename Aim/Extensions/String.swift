//
//  String.swift
//  Aim
//
//  Created by Alexandru Turcanu on 12/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import Foundation

extension String {
    func containsIllegalCharacters() -> Bool {

        let illegalCharacters = "()-+{}[]|\\/"

        for char in illegalCharacters {
            if self.contains(char) {
                return true
            }
        }

        if self.contains("/") {
            return true
        }

        if self.contains("\"") {
            return true
        }

        return false
    }
}
