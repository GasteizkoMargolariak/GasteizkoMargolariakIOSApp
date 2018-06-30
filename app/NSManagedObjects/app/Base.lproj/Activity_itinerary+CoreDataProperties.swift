//
//  Activity_itinerary+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity_itinerary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity_itinerary> {
        return NSFetchRequest<Activity_itinerary>(entityName: "Activity_itinerary")
    }

    @NSManaged public var activity: Int32
    @NSManaged public var description_en: String?
    @NSManaged public var description_es: String?
    @NSManaged public var description_eu: String?
    @NSManaged public var end: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?
    @NSManaged public var place: Int32
    @NSManaged public var route: Int32
    @NSManaged public var start: NSDate?

}
