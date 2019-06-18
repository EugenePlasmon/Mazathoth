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
    
    func filesFromDocumentsFolder() throws -> [FileSystemEntity] {
        guard let directory = directories.first else {
            return []
        }
        let files = try FileManager.default.contentsOfDirectory(atPath: directory)
        return files.compactMap {
            let absolutePath = (directory as NSString).appendingPathComponent($0)
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: absolutePath), let type = attributes[.type] as? FileAttributeType else {
                return nil
            }
            switch type {
            case .typeRegular:
                return File(name: $0, absolutePath: absolutePath)
            case .typeDirectory:
                return Folder(name: $0, absolutePath: absolutePath)
            default:
                break
            }
            return nil
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
