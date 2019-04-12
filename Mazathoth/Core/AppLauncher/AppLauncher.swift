//
//  AppLauncher.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 17/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

final class AppLauncher {
    
    weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let filesVC = InternalFilesViewController(fetcher: InternalFilesFetcher())
        let navVC = UINavigationController(rootViewController: filesVC)
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
}
