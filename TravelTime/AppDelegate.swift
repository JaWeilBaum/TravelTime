//
//  AppDelegate.swift
//  TravelTime
//
//  Created by Léon Friedmann on 05.01.17.
//  Copyright © 2017 Léon Friedmann. All rights reserved.
//

import UIKit
import CoreData
import SwiftHTTP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let settings = UIUserNotificationSettings(types: .alert, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Complete");
        completionHandler(UIBackgroundFetchResult.newData)
        
        getData();
    }
    
    func getData() -> Void{
        var data : String = ""
        var timeWithoutTraffic = -1
        var timeWithTraffic = -1
        print("Loading")
        do {
            //the url sent will be https://google.com?hello=world&param2=value2
            let opt = try HTTP.GET("https://maps.googleapis.com/maps/api/directions/json?", parameters: ["key" : "AIzaSyCTU25VYbmcvu4geQ7jN5FONhlqfV8Lprc", "origin" : "80801 München Wilhelmsstrasse 43", "destination" : "Reinhold-Würth-Straße 12, 74653 Künzelsau" , "units" : "metric" , "departure_time" : "now"])
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                data = response.text!
                if response.statusCode == 200 {
                    
                    let duartionIndex = data.index(of: "duration")
                    data = data.substring(from: duartionIndex!)
                    
                    let endIndex = data.index(of: "end_address")
                    data = data.substring(to: endIndex!)
                    
                    let valueIndex = data.index(of: "\"value\" : ");
                    var duration = data.substring(from: valueIndex!)
                    
                    let endValueIndex = duration.index(of: "}")
                    duration = duration.substring(to: endValueIndex!)
                    
                    var time = ""
                    var counter = 0
                    for c in duration.characters {
                        if counter >= 10 {
                            time.append(c)
                        }
                        counter += 1
                    }
                    timeWithoutTraffic = Int(time.trimmingCharacters(in: .whitespacesAndNewlines))!
                    //print("Ohne Verkehr: \(timeWithoutTraffic!)")
                    
                    let durationWithTrafficIndex = data.index(of: "duration_in_traffic")
                    data = data.substring(from: durationWithTrafficIndex!)
                    
                    let valueTIndex = data.index(of: "\"value\" : ");
                    var durationT = data.substring(from: valueTIndex!)
                    
                    let endValueTIndex = durationT.index(of: "}")
                    durationT = durationT.substring(to: endValueTIndex!)
                    
                    var timeT = ""
                    var counterT = 0
                    for c in durationT.characters {
                        if counterT >= 10 {
                            timeT.append(c)
                        }
                        counterT += 1
                    }
                    timeWithTraffic = Int(timeT.trimmingCharacters(in: .whitespacesAndNewlines))!
                }
                //data = (timeWithoutTraffic, timeWithTraffic)
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        print("Loading done \nResult = \(data)")
        
        while timeWithTraffic == -1 || timeWithoutTraffic == -1 {
            
        }
        print("HAAAALLLOOOO")
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications on iOS8"
        localNotification.alertBody = "Zeit Unterschied: \(timeWithTraffic - timeWithoutTraffic) Sekunden"
        localNotification.fireDate = NSDate() as Date
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TravelTime")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

