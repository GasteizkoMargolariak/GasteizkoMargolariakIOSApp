//
//  Activity+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var after_en: String?
    @NSManaged public var after_es: String?
    @NSManaged public var after_eu: String?
    @NSManaged public var album: Int32
    @NSManaged public var city: String?
    @NSManaged public var comments: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var dtime: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var inscription: Int16
    @NSManaged public var max_people: Int16
    @NSManaged public var people: Int16
    @NSManaged public var permalink: String?
    @NSManaged public var price: Int16
    @NSManaged public var text_en: String?
    @NSManaged public var text_es: String?
    @NSManaged public var text_eu: String?
    @NSManaged public var title_en: String?
    @NSManaged public var title_es: String?
    @NSManaged public var title_eu: String?

}
