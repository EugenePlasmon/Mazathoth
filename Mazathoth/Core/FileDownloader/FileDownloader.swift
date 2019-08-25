//
//  FileDownloader.swift
//  Mazathoth
//
//  Created by Nadezhda on 27/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class FileDownloader {
     
    private var activeDownloads: [URL: DownloadEntity] = [:]
    
    func getFiles() -> [FileSystemEntity] {
        var files: [FileSystemEntity] = []
        for download in activeDownloads.values {
            guard let file = download.file else {
                return []
            }
            files.append(file)
        }
        return files
    }
    
    func getFileInfo(from url: URL, completion: @escaping (_ : String?) -> Void) {
        let download = DownloadEntity(url: url)
        download.task = Task(url: url)
        download.task?.onGetName = { name in
            download.file = File(name: name, absolutePath: "", isDownloading: true, download: download)
            completion(name)
        }
        download.task?.resumeDataTask()
        self.activeDownloads[url] = download
    }
    
    func downloadFile(from url: URL, completion: @escaping (_ : String?) -> Void) {
        guard let download = activeDownloads[url] else { return }
        download.task?.onGetDownloadProcess = { (progress, totalSize) in
            download.progress = progress
            download.totalSize = totalSize
        }
        download.task?.onCompletionDownload = { path in
            self.activeDownloads[url] = nil
            completion(path)
        }
        download.task?.resumeDownloadTask()
        download.isActive = true
    }
    
    func cancelDownload(from url: URL) {
        guard let download = activeDownloads[url] else { return }
        download.task?.cancel()
        self.activeDownloads[url] = nil
    }
    
    func pauseDownload(from url: URL) {
        guard let download = activeDownloads[url], download.isActive else {
            return
        }
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        download.isActive = false
    }
    
    func resumeDownload(from url: URL, completion: @escaping (_ : String?) -> Void)  {
        guard let download = activeDownloads[url] else { return }
        if let resumeData = download.resumeData {
            download.task = Task(data: resumeData)
        } else {
            download.task = Task(url: url)
        }
        download.task?.resumeDownloadTask()
        download.isActive = true
        download.task?.onCompletionDownload = { path in
            self.activeDownloads[url] = nil
            download.isActive = false
            completion(path)
        }
    }
}
