//
//  InternalFilesModuleBuilder.swift
//  Mazathoth
//
//  Created by Nadezhda on 10/07/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

final class InternalFilesModuleBuilder {
    
    func build(path: String?) -> InternalFilesViewController {
        let internalFileManager = InternalFileManager(path: path)
        return InternalFilesViewController(internalFileManager: internalFileManager)
    }
}
