//
//  InternalFilesManagerInterface.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 17/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

protocol InternalFilesManagerInterface {
    
    func fetchFiles() throws -> [FileSystemEntity]
    
    func addFolderToFolder(withName name: String)
    
    func removeInternalFile(atPath absolutePath: String)
    
    func moveInternalFile(atPath srcPath: String, toPath dstPath: String)
}
