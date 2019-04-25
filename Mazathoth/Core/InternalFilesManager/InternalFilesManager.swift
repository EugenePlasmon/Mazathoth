//
//  InternalFilesManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesManager: InternalFilesManagerInterface {
    
    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
    
    // MARK: - Fetch InternalFiles from Document directory
    
    func filesFromDocumentsFolder() throws -> [InternalFile] {
        guard let directory = directories.first else {
            return []
        }
        let files = try FileManager.default.contentsOfDirectory(atPath: directory)
        return files.compactMap {
            let absolutePath = (directory as NSString).appendingPathComponent($0)
            return InternalFile(name: $0, absolutePath: absolutePath)
        }
    }
    
    // MARK: - Add folder to Document directory
    
    func addFolderToDocumentsFolder(withName name: String) {
        guard let directory = directories.first else {
            return
        }
        let absolutePath = (directory as NSString).appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
