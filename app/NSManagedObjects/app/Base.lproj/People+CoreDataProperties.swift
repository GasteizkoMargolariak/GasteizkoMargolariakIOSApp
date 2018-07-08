//
//  People+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension People {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<People> {
        return NSFetchRequest<People>(entityName: "People")
    }

    @NSManaged public var id: Int32
    @NSManaged public var link: String?
    @NSManaged public var name_en: String?
    @NSManaged public var name_es: String?
    @NSManaged public var name_eu: String?

}
