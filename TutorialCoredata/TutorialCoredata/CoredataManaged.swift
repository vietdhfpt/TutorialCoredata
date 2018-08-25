//
//  CoredataManaged.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import Foundation
import CoreData

class CoredataManaged {
    
    var modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
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
