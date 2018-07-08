//
//  Festival_day+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Festival_day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Festival_day> {
        return NSFetchRequest<Festival_day>(entityName: "Festival_day")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var max_people: Int16
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?
    @NSManaged public var people: Int16
    @NSManaged public var price: Int32

}
