//
//  Array+Extensions.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

public extension Array {
    
    subscript(safe index: Index) -> Element? {
        return (startIndex..<endIndex) ~= index ? self[index] : nil
    }
    
    mutating func appendIfExists(_ elements: Element?...) {
        self.append(contentsOf: elements.compactMap { $0 })
    }
    
    mutating func appendIfExists(contentsOf arraysOfElements: [Element]?...) {
        for array in arraysOfElements {
            array >>- { self.append(contentsOf: $0) }
        }
    }
}
