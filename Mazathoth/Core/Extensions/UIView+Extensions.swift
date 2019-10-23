//
//  UIView+Extensions.swift
//  Mazathoth
//
//  Created by Nadezhda on 23/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

extension UIView {
    
    var snapshot: UIView? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        return snapshot
    }
}
