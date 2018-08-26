//
//  CoreDataStack.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TutorialCoredata")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if self.managedContext.hasChanges {
            do {
                try self.managedContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
