//
//  String+Extensions.swift
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
    
    func appendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    func unifyName(withAlreadyExistingNames names: [String]) -> String {
        var name = self.deletingPathExtension
        var count = 0
        let names: Set<String> = Set((names.map { $0.deletingPathExtension }))
        while names.contains(name) {
            count += 1
            name = self.deletingPathExtension + "-" + String(count)
        }
        return name.appendingPathExtension(self.pathExtension) ?? name
    }
    
    func addColorAttribute(_ color: UIColor, for range: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let range = (self as NSString).range(of: range, options: .caseInsensitive)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        return attributedString
    }
}
