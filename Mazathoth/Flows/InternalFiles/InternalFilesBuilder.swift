//
//  InternalFilesBuilder.swift
//  Mazathoth
//
//  Created by Nadezhda on 10/07/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

final class InternalFilesBuilder {
    
    func build(path: String?) -> InternalFilesViewController {
        let internalFilesManager = InternalFilesManager(path: path)
        return InternalFilesViewController(internalFilesManager: internalFilesManager)
    }
    
}
