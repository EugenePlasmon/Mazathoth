//
//  File.swift
//  Mazathoth
//
//  Created by Nadezhda on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

struct File: FileSystemEntity {
    let name: String
    let absolutePath: String
    let isDownloading: Bool
    let downloadEntity: DownloadEntity?
    var isDownloadActive: Bool {
        return downloadEntity?.isActive ?? false
    }
    
    init(name: String, absolutePath: String, isDownloading: Bool = false, download: DownloadEntity? = nil) {
        self.name = name
        self.absolutePath = absolutePath
        self.isDownloading = isDownloading
        self.downloadEntity = download
    }
}
