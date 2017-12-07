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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog(" ---- Application Launches ----")
        NSLog(" ==============================")
        NSLog("\n")
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(Date().timeIntervalSince1970)
            let refreshToken = GlobalHandler.sharedInstance.esdrAccount.refreshToken!
            let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            
            // response handler
            func responseHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                if error != nil {
                    GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens("", refreshToken: "", expiresAt: 0)
                    NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                } else if let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary {
                    let access_token = data.value(forKey: "access_token") as? String
                    let refresh_token = data.value(forKey: "refresh_token") as? String
                    let expires_in = data.value(forKey: "expires_in") as? Int
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
            
            GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let globalHandler = GlobalHandler.sharedInstance
        globalHandler.refreshTimer.stopTimer()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let globalHandler = GlobalHandler.sharedInstance
        NSLog("applicationDidBecomeActive: now calling updateReadings()")
        globalHandler.updateReadings()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Background App Refresh
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if GlobalHandler.sharedInstance.settingsHandler.userLoggedIn {
            let timestamp = Int(Date().timeIntervalSince1970)
            let refreshToken = GlobalHandler.sharedInstance.esdrAccount.refreshToken!
            let expiresAt = GlobalHandler.sharedInstance.esdrAccount.expiresAt!
            
            // response handler
            func responseHandler(_ url: URL?, response: URLResponse?, error: Error?) {
                if error != nil {
                    NSLog("requestEsdrRefresh received error from refreshToken=\(refreshToken)")
                    completionHandler(UIBackgroundFetchResult.failed)
                } else if let data = (try? JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: [])) as? NSDictionary {
                    let access_token = data.value(forKey: "access_token") as? String
                    let refresh_token = data.value(forKey: "refresh_token") as? String
                    let expires_in = data.value(forKey: "expires_in") as? Int
                    if access_token != nil && refresh_token != nil && expires_in != nil {
                        NSLog("found access_token=\(access_token), refresh_token=\(refresh_token)")
                        GlobalHandler.sharedInstance.esdrLoginHandler.updateEsdrTokens(access_token!, refreshToken: refresh_token!, expiresAt: timestamp+expires_in!)
                        NSLog("Background fetch was successful!")
                        completionHandler(UIBackgroundFetchResult.newData)
                    } else {
                        GlobalHandler.sharedInstance.esdrLoginHandler.removeEsdrAccount()
                        NSLog("Failed to grab access/refresh token(s)")
                        completionHandler(UIBackgroundFetchResult.failed)
                    }
                }
            }
            
            if !Constants.REFRESHES_ESDR_TOKEN {
                NSLog("Background fetch was successful (REFRESHES_ESDR_TOKEN not set)")
                completionHandler(UIBackgroundFetchResult.newData)
            } else {
                GlobalHandler.sharedInstance.esdrAuthHandler.requestEsdrRefresh(refreshToken, responseHandler: responseHandler)
            }
        } else {
            NSLog("Background fetch was successful! (not logged in)")
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.cmucreatelab.tasota.AirPrototype" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "AirPrototype", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("AirPrototype.sqlite")
        var error: Error? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
//            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            // attempting light migration
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as AnyObject
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!._userInfo)")
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

