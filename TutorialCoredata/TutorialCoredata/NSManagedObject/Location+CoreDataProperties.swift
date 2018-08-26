//
//  Location+CoreDataProperties.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var zipcode: String?
    @NSManaged public var state: String?
    @NSManaged public var distance: Float
    @NSManaged public var country: String?
    @NSManaged public var city: String?
    @NSManaged public var address: String?
    @NSManaged public var venue: Venue?

}
