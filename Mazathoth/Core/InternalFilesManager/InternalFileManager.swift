//
//  InternalFileManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFileManager: InternalFileManagerInterface {
    
    private var documentsDirectoryPath: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
    }
    private var path: String?
    
    // MARK: - Init
    
    init(path: String?) {
        guard let path = path ?? self.documentsDirectoryPath else { return }
        self.path = path
    }
    
    // MARK: - Fetch Files from directory
    
    func fetchFiles() throws -> [FileSystemEntity] {
        guard let directoryPath = self.path else {
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
    
    func addFolder(withName name: String) {
        guard let directoryPath = self.path else {
            return
        }
        let absolutePath = directoryPath.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - File actions
    
    func removeInternalFile(atPath absolutePath: String) {
        guard FileManager.default.fileExists(atPath: absolutePath) else { return }
        do {
            try FileManager.default.removeItem(atPath: absolutePath)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func moveInternalFile(atPath srcPath: String, toPath dstPath: String) {
        guard FileManager.default.fileExists(atPath: srcPath) else { return }
        do {
            try FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
        } catch {
            print(error.localizedDescription)
        }
    }
}
