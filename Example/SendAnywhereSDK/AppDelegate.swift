//
//  AppDelegate.swift
//  SendAnywhereSDK
//
//  Created by doyoung park on 03/14/2017.
//  Copyright (c) 2017 doyoung park. All rights reserved.
//

import UIKit
import SendAnywhereSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SendAnywhere.withKey("INPUT_YOUR_API_KEY")
        
        // If you want to download files of document type, Uncomment this line.
        //SendAnywhere.sharedInstance().downloadFileFilter = [.document]
        
        // If you want to download files of image type, Uncomment this line.
        //SendAnywhere.sharedInstance().downloadFileFilter = [.image]
        
        // If you want to download files of audio type, Uncomment this line.
        //SendAnywhere.sharedInstance().downloadFileFilter = [.audio]
        
        // If you want to download files of media type, Uncomment this line.
        //SendAnywhere.sharedInstance().downloadFileFilter = [.image, .video, .audio]
        
        // If you want to download files of custom file pattern, Uncomment this line.
        //SendAnywhere.sharedInstance().customFilePattern = "((.+)(\\.(?i)(jpg|jpeg|png|gif))$)"
        
        SendAnywhere.sharedInstance().transferTimeout = 5
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

