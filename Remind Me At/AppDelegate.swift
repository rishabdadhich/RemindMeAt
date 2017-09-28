//
//  AppDelegate.swift
//  Remind Me At
//
//  Created by Rishabh on 27/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   
    var window: UIWindow?
    
    let coreDataManager = CoreDataManager.sharedInstance
    let locationManager = LocationManager()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // facebook//
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Request notification authorisation
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in }
        
        // check for user login
        if (UserDefaults.standard.object(forKey: "login") == nil)
        {
            UserDefaults.standard.set(false, forKey: "login")
        }
       else if (UserDefaults.standard.bool(forKey: "login") == true)
        {
          screenlaunch(str: "reminderViewController")
            }
        else {
            screenlaunch(str: "viewController")
        }
        return true
        
    }
    
    func screenlaunch(str : String )
    {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: str)
        let navigationController :UINavigationController = UINavigationController(rootViewController: homeViewController)
 //       navigationController.isNavigationBarHidden = true
        window!.rootViewController = nil
        window!.rootViewController = navigationController
        window?.makeKey()
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataManager.saveContext()
    }
    
    
    
}

