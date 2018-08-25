//
//  Bowtie+CoreDataProperties.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/24/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> {
        return NSFetchRequest<Bowtie>(entityName: "Bowtie")
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var searchKey: String?
    @NSManaged public var tinColor: NSObject?
    @NSManaged public var photoData: Data?
    @NSManaged public var rating: Double
    @NSManaged public var timesWorn: Int32
    @NSManaged public var lastWorn: Date?

}
