//
//  InternalFilesFetcher.swift
//  Mazathoth
//
//  Created by Nadezhda on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class InternalFilesFetcher {
    
    // MARK: - Fetch InternalFiles from Document directory
    
    func filesFromDocumentsFolder() -> [InternalFile] {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        guard let directory = directories.first else {
            return []
        }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directory)
            return files.compactMap {
                let absolutePath = (directory as NSString).appendingPathComponent($0)
                return InternalFile(name: $0, absolutePath: absolutePath)
            }
        } catch {
            // TODO: Add Error Handling
            print("Error: \(error)")
        }
        return []
    }
}
