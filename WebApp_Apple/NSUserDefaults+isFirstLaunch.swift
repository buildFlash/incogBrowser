//
//  NSUserDefaults+isFirstLaunch.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 29/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import Foundation

extension UserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    static func isFirstLaunch() -> Bool {
        let firstLaunchFlag = "FirstLaunchFlag"
        let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
        if (isFirstLaunch) {
            UserDefaults.standard.set("false", forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
