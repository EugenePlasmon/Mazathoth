//
//  CGFloat+Extensions.swift
//  Mazathoth
//
//  Created by Nadezhda on 14.01.2020.
//  Copyright © 2020 plasmon. All rights reserved.
//

import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}
