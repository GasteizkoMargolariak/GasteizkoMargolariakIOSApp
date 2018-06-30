//
//  Sponsor+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Sponsor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sponsor> {
        return NSFetchRequest<Sponsor>(entityName: "Sponsor")
    }

    @NSManaged public var address_en: String?
    @NSManaged public var address_es: String?
    @NSManaged public var address_eu: String?
    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var lat: Double
    @NSManaged public var link: String?
    @NSManaged public var local: Bool
    @NSManaged public var lon: Double
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?
    @NSManaged public var text_en: String?
    @NSManaged public var text_es: String?
    @NSManaged public var text_eu: String?

}
