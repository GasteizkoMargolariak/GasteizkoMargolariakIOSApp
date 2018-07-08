//
//  Festival+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Festival {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Festival> {
        return NSFetchRequest<Festival>(entityName: "Festival")
    }

    @NSManaged public var id: Int32
    @NSManaged public var img: String?
    @NSManaged public var summary_en: String?
    @NSManaged public var summary_es: String?
    @NSManaged public var summary_eu: String?
    @NSManaged public var text_en: String?
    @NSManaged public var text_es: String?
    @NSManaged public var text_eu: String?
    @NSManaged public var year: Int32

}
