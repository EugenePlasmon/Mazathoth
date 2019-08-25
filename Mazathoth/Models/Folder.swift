//
//  Folder.swift
//  Mazathoth
//
//  Created by Nadezhda on 18/06/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

struct Folder: FileSystemEntity {
    let name: String
    let absolutePath: String
    let isDownloading: Bool = false
    let downloadEntity: DownloadEntity? = nil
    let isDownloadActive: Bool = false
}
