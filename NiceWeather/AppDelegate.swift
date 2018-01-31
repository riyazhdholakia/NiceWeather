//
//  AppDelegate.swift
//  NiceWeather
//
//  Created by Nathan Hosselton on 8/6/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
//import DarkSky

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        api_key = "fdbd5a438d0133a39842235b1c042730"
        return true
    }

}
