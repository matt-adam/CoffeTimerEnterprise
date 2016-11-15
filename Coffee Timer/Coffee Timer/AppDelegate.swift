//
//  AppDelegate.swift
//  Coffee Timer
//
//  Created by Ash Furrow on 2014-07-26.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack()
    }()

    func method (_ arg: String!) {
        print(arg)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        
        print("Application has launched.")

        coreDataStack.loadDefaultDataIfFirstLaunch()

        window?.tintColor = UIColor(red:0.95, green:0.53, blue:0.27, alpha:1)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("Application has resigned active.")

        coreDataStack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application has entered background.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Application has entered foreground.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application has become active.")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will terminate.")
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("Application received local notification.")

        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }
}

