//
//  DownloadManager.swift
//  Mazathoth
//
//  Created by Nadezhda on 24/10/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

final class DownloadManager {
    
    typealias OnGetFileInfoClosure = () -> Void
    typealias OnDownloadFileClosure = (_ srcPath: String, _ dstPath: String) -> Void
    var onGetFileInfo: OnGetFileInfoClosure?
    var onDownloadFile: OnDownloadFileClosure?
    
    private let fileDownloader = FileDownloader()
    private let documentsDirectoryPath: String
    private let internalFiles: [FileSystemEntity]
    var activeDownloads: [FileSystemEntity] {
        get { return self.fileDownloader.getFiles() }
    }
    
    // MARK: - Init
    
    init(documentsDirectoryPath: String) {
        self.documentsDirectoryPath = documentsDirectoryPath
        let internalFileManager = InternalFileManager(path: documentsDirectoryPath)
        self.internalFiles = (try? internalFileManager.fetchFiles()) ?? []
    }
    
    // MARK: - Internal
    
    func downloadFile(from url: String) {
        guard let url = (URL(string: url)) else { return }
        var fileName: String = url.lastPathComponent
        self.fileDownloader.getFileInfo(from: url) { [weak self] name in
            self?.onGetFileInfo?()
            guard let name = name else { return }
            fileName = name
        }
        self.fileDownloader.downloadFile(from: url) { [weak self] srcPath in
            guard let self = self, let srcPath = srcPath else {
                return
            }
            var dstPath = self.documentsDirectoryPath.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: dstPath) {
                let fileNames = self.internalFiles.map { $0.name }
                dstPath = self.documentsDirectoryPath.appendingPathComponent(fileName.unifyName(withAlreadyExistingNames: fileNames))
            }
            self.onDownloadFile?(srcPath, dstPath)
        }
    }
    
    func cancelDownload(from url: URL) {
        self.fileDownloader.cancelDownload(from: url)
    }
    
    func pauseDownload(from url: URL) {
        self.fileDownloader.pauseDownload(from: url)
    }
    
    func resumeDownload(from url: URL, name: String) {
        self.fileDownloader.resumeDownload(from: url) { srcPath in
            guard let srcPath = srcPath else { return }
            var dstPath = self.documentsDirectoryPath.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: dstPath) {
                let fileNames = self.internalFiles.map { $0.name }
                dstPath = self.documentsDirectoryPath.appendingPathComponent(name.unifyName(withAlreadyExistingNames: fileNames))
            }
            self.onDownloadFile?(srcPath, dstPath)
        }
    }
}


