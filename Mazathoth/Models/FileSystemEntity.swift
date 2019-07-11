//
//  FileSystemEntity.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/06/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

protocol FileSystemEntity {
    var name: String { get }
    var absolutePath: String { get }
}
