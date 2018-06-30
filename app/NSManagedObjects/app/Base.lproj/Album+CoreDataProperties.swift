//
//  Album+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var description_en: String?
    @NSManaged public var description_es: String?
    @NSManaged public var description_eu: String?
    @NSManaged public var id: Int32
    @NSManaged public var open: Int16
    @NSManaged public var permalink: String?
    @NSManaged public var time: NSDate?
    @NSManaged public var title_en: String?
    @NSManaged public var title_es: String?
    @NSManaged public var title_eu: String?

}
