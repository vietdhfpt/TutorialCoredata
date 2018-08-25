//
//  Walk+CoreDataProperties.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/25/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dog: Dog?
}
