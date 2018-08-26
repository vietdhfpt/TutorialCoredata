//
//  AppDelegate.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/24/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var coreDataStack = CoreDataStack()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let navController = self.window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? ViewController else {
            return true
        }
        
        viewController.coreDataStack = self.coreDataStack
        self.importJSONSeedDataIfNeed()
        return true
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
        self.coreDataStack.saveContext()
    }
    
    func importJSONSeedDataIfNeed() {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        let count = try! self.coreDataStack.managedContext.count(for: fetchRequest)
        
        guard count == 0 else {
            return
        }
        
        do {
            let results = try self.coreDataStack.managedContext.fetch(fetchRequest)
            results.forEach { self.coreDataStack.managedContext.delete($0) }
            self.coreDataStack.saveContext()
            
            self.importJSONSeedData()
            
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
    }

    func importJSONSeedData() {
        let managedContext = self.coreDataStack.managedContext
        let jsonUrl = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = NSData(contentsOf: jsonUrl)! as Data
        
        let venueEntity = NSEntityDescription.entity(forEntityName: "Venue", in: managedContext)!
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
        let priceEntity = NSEntityDescription.entity(forEntityName: "PriceInfo", in: managedContext)!
        let statsEntity = NSEntityDescription.entity(forEntityName: "Stats", in: managedContext)!
        
        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: AnyObject]
        let responseDict = jsonDict["response"] as! [String: AnyObject]
        let jsonArray = responseDict["venues"] as! [[String: AnyObject]]
        
        for jsonDictionary in jsonArray {
            let venueName = jsonDictionary["name"] as? String
            let contactDict = jsonDictionary["contact"] as! [String: String]
            let venuePhone = contactDict["phone"]
            
            let specialsDict = jsonDictionary["specials"] as! [String: AnyObject]
            let specialCount = specialsDict["count"] as? NSNumber
            
            let locationDict = jsonDictionary["location"] as! [String: AnyObject]
            let priceDict = jsonDictionary["price"] as! [String: AnyObject]
            let statsDict = jsonDictionary["stats"] as! [String: AnyObject]
            
            let location = Location(entity: locationEntity, insertInto: managedContext)
            location.address = locationDict["address"] as? String
            location.city = locationDict["city"] as? String
            location.state = locationDict["state"] as? String
            location.zipcode = locationDict["zipcode"] as? String
            let distance = locationDict["distance"] as? NSNumber
            location.distance = distance!.floatValue
            
            let categoty = Category(entity: categoryEntity, insertInto: managedContext)
            
            let priceInfo = PriceInfo(entity: priceEntity, insertInto: managedContext)
            priceInfo.priceCategory = priceDict["currency"] as? String
            
            let stats = Stats(entity: statsEntity, insertInto: managedContext)
            let checkins = statsDict["checkinsCount"] as? NSNumber
            stats.checkinsCount = checkins!.int32Value
            let tipCount = statsDict["tipCount"] as? NSNumber
            stats.tipCount = tipCount!.int32Value
            
            let venue = Venue(entity: venueEntity, insertInto: managedContext)
            venue.name = venueName
            venue.phone = venuePhone
            venue.category = categoty
            venue.specialCount = specialCount!.int32Value
            venue.location = location
            venue.priceInfo = priceInfo
            venue.stats = stats
            
        }
        
        self.coreDataStack.saveContext()
    }
}

