//
//  Festival_event+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Festival_event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Festival_event> {
        return NSFetchRequest<Festival_event>(entityName: "Festival_event_city")
    }

    @NSManaged public var day: NSDate?
    @NSManaged public var description_en: String?
    @NSManaged public var description_es: String?
    @NSManaged public var description_eu: String?
    @NSManaged public var end: NSDate?
    @NSManaged public var host: Int32
    @NSManaged public var id: Int32
    @NSManaged public var place: Int32
    @NSManaged public var route: Int32
    @NSManaged public var sponsor: Int32
    @NSManaged public var start: NSDate?
    @NSManaged public var title_en: String?
    @NSManaged public var title_es: String?
    @NSManaged public var title_eu: String?

}
