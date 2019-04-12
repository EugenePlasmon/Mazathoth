//
//  InternalFilesFetcherInterface.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 17/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

protocol InternalFilesFetcherInterface {
    
    func filesFromDocumentsFolder() throws -> [InternalFile]
}
