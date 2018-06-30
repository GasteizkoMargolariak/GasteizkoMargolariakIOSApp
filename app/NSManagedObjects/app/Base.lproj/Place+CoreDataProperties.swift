//
//  Place+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var address_en: String?
    @NSManaged public var address_es: String?
    @NSManaged public var address_eu: String?
    @NSManaged public var cp: String?
    @NSManaged public var id: Int32
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?

}
