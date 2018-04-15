//
//  AppDelegate.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession
        identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
}

