//
//  AppDelegate.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 08/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let defaults = UserDefaults.standard
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(checkOrientation(viewController: self.window?.rootViewController)))
    }
    
    func checkOrientation(viewController:UIViewController?)-> Int{
        
        if(viewController == nil){
            
            return Int(UIInterfaceOrientationMask.all.rawValue)//All means all orientation
            
        }else if (viewController is HomeVC){
            
            return Int(UIInterfaceOrientationMask.portrait.rawValue)//This is sign in view controller that i only want to set this to portrait mode only
            
        }else{
            
            return checkOrientation(viewController: viewController!.presentedViewController)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("app terminated")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if response.actionIdentifier == "remindLater" {
//            let newDate = Date(timeInterval: 900, since: Date())
//            scheduleNotification(at: newDate)
//        }
//    }
//}
