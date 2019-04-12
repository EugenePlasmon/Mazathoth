//
//  CGColor+Extensions.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

extension CGColor {
    public var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}
