//
//  DownloadEntity.swift
//  Mazathoth
//
//  Created by Nadezhda on 27/08/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

class DownloadEntity {
    var isActive = false
    var progress: Float = 0
    var totalSize: String = "0"
    var resumeData: Data?
    var task: Task?
    var file: FileSystemEntity?
    var url: URL
    
    // MARK: - Init
    
    init(url: URL) {
        self.url = url
    }
}
