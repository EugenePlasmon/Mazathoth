//
//  Int+Extensions.swift
//  Mazathoth
//
//  Created by Nadezhda on 15.11.2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

extension Int {
    func addDeclensionFrom(nominativeSingular: String, genitiveSingular: String, genitivePlural: String) -> String {
        var number: Int = abs(self)
        number %= 100
        if (number >= 5 && number <= 20) {
            return String(number) + " " + genitivePlural
        }
        number %= 10
        if (number == 1) {
            return String(number) + " " + nominativeSingular
        }
        if (number >= 2 && number <= 4) {
            return String(number) + " " + genitiveSingular
        }
        return String(number) + " " + genitivePlural
    }
}
