//
//  Category+CoreDataProperties.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var catogoryID: String?
    @NSManaged public var name: String?
    @NSManaged public var venue: Venue?

}
