//
//  InternalFilesManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesManager: InternalFilesManagerInterface {
    
    private var documentsDirectoryPath: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
    }
    private let path: String?
    
    // MARK: - Init
    
    init(path: String?) {
        self.path = path
    }
    
    // MARK: - Fetch Files from directory
    
    func fetchFiles() throws -> [FileSystemEntity] {
        guard let directoryPath = self.path ?? self.documentsDirectoryPath else {
            return []
        }
        let files = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
        return files.compactMap {
            let absolutePath = directoryPath.appendingPathComponent($0)
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
    
    // MARK: - Add folder to folder
    
    func addFolderToFolder(withName name: String) {
        guard let directoryPath = self.path ?? self.documentsDirectoryPath else {
            return
        }
        let absolutePath = directoryPath.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}
