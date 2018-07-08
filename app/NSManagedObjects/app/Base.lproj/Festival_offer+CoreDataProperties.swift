//
//  Festival_offer+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Festival_offer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Festival_offer> {
        return NSFetchRequest<Festival_offer>(entityName: "Festival_offer")
    }

    @NSManaged public var days: Int16
    @NSManaged public var description_en: String?
    @NSManaged public var description_es: String?
    @NSManaged public var description_eu: String?
    @NSManaged public var id: Int32
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?
    @NSManaged public var price: Int16
    @NSManaged public var year: Int32

}
