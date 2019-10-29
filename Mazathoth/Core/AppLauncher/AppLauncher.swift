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
        let filesVC = InternalFilesModuleBuilder().build(path: nil)
        let navVC = UINavigationController(rootViewController: filesVC)
        self.setNavigationBar(for: navVC)
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
    
    private func setNavigationBar(for navVC: UINavigationController) {
        
        navVC.navigationBar.barTintColor = .white
        navVC.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navVC.navigationBar.shadowImage = UIImage()
    }
}
