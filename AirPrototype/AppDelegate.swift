//
//  AppDelegate.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // TODO perform esdr token checks
        NSLog(" ---- Application Launches ----")
        NSLog(" ==============================")
        NSLog("\n")
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let refreshToken = GlobalHandler.sharedInstance.esdrAccount.accessToken!
            let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            
            // response handler
            func responseHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                if error != nil {
                    NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                } else {
                    let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                    let access_token = data!.valueForKey("access_token") as? String
                    let refresh_token = data!.valueForKey("refresh_token") as? String
                    let expires_in = data!.valueForKey("expires_in") as? Int
                    if access_token != nil && refresh_token != nil && expires_in != nil {
                        NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                        GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                        NSLog("Updated ESDR Tokens!")
                    } else {
                        GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                        NSLog("Failed to grab access/refresh token(s)")
                    }
                }
            }
            
            let updatingTokens = GlobalHandler.sharedInstance.esdrAuthHandler.checkAndRefreshEsdrTokens(expiresAt, currentTime: timestamp, refreshToken: refreshToken, responseHandler: responseHandler)
            if !updatingTokens {
                UIAlertView.init(title: "www.specksensor.com", message: "Your session has timed out. Please log in.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.refreshTimer.stopTimer()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let globalHandler = GlobalHandler.sharedInstance
        NSLog("applicationDidBecomeActive: now calling updateReadings()")
        globalHandler.updateReadings()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Background App Refresh
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let refreshToken = GlobalHandler.sharedInstance.esdrAccount.accessToken!
            let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            
            // response handler
            func responseHandler(url: NSURL?, response: NSURLResponse?, error: NSError?) {
                if error != nil {
                    NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                    completionHandler(UIBackgroundFetchResult.Failed)
                } else {
                    let data = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: [])) as? NSDictionary
                    let access_token = data!.valueForKey("access_token") as? String
                    let refresh_token = data!.valueForKey("refresh_token") as? String
                    let expires_in = data!.valueForKey("expires_in") as? Int
                    if access_token != nil && refresh_token != nil && expires_in != nil {
                        NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                        GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                        NSLog("Background fetch was successful!")
                        completionHandler(UIBackgroundFetchResult.NewData)
                    } else {
                        GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                        NSLog("Failed to grab access/refresh token(s)")
                        completionHandler(UIBackgroundFetchResult.Failed)
                    }
                }
            }
            
            let updatingTokens = GlobalHandler.sharedInstance.esdrAuthHandler.checkAndRefreshEsdrTokens(expiresAt, currentTime: timestamp, refreshToken: refreshToken, responseHandler: responseHandler)
            if !updatingTokens {
                NSLog("Background fetch was successful (esdr tokens expired)")
                completionHandler(UIBackgroundFetchResult.NewData)
            }
        } else {
            NSLog("Background fetch was successful! (not logged in)")
            completionHandler(UIBackgroundFetchResult.NewData)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.cmucreatelab.tasota.AirPrototype" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("AirPrototype", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("AirPrototype.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
//            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            // attempting light migration
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

