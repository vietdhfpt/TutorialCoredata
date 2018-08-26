//
//  PriceInfo+CoreDataProperties.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//
//

import Foundation
import CoreData


extension PriceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo")
    }

    @NSManaged public var priceCategory: String?
    @NSManaged public var venue: Venue?

}
