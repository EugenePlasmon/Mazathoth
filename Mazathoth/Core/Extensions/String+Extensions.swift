//
//  String + Extensions.swift
//  Mazathoth
//
//  Created by Nadezhda on 17/07/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

extension String {
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
