//
//  FileDownloader.swift
//  Mazathoth
//
//  Created by Nadezhda on 24/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class Task: NSObject {
    
    let url: URL?
    var onGetName: ((String) -> Void)?
    var onCompletionDownload: ((String) -> Void)?
    var onGetDownloadProcess: ((Float, String) -> Void)?
    
    private var dataTask: URLSessionDataTask?
    private(set) var downloadTask: URLSessionDownloadTask?
    
    init(url: URL) {
        self.url = url
        super.init()
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.dataTask = urlSession.dataTask(with: url)
        self.downloadTask = urlSession.downloadTask(with: url)
    }
    
    init(data: Data) {
        self.url = nil
        super.init()
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.downloadTask = urlSession.downloadTask(withResumeData: data)
    }
    
    func resumeDataTask() {
        self.dataTask?.resume()
    }
    
    func resumeDownloadTask() {
        self.downloadTask?.resume()
    }
    
    func cancel() {
        self.downloadTask?.cancel()
    }
    
    func cancel(byProducingResumeData completionHandler: @escaping (Data?) -> Void) {
        self.downloadTask?.cancel(byProducingResumeData: completionHandler)
    }
    
}

extension Task: URLSessionDataDelegate, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            completionHandler(.cancel)
            return
        }
        if let name = response.suggestedFilename {
            self.onGetName?(name)
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        var path = location.absoluteString
        path = path.replacingOccurrences(of: "file://", with: "")
        self.onCompletionDownload?(path)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        self.onGetDownloadProcess?(progress, totalSize)
    }
}





