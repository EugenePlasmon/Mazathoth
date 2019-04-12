//
//  AppDelegate.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 09/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var appLauncher: AppLauncher?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.appLauncher = AppLauncher(window: self.window)
        self.appLauncher?.start()
        return true
    }
}
