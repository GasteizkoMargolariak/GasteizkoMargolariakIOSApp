//
//  Photo+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var description_en: String?
    @NSManaged public var description_es: String?
    @NSManaged public var description_eu: String?
    @NSManaged public var dtime: NSDate?
    @NSManaged public var file: String?
    @NSManaged public var height: Int32
    @NSManaged public var id: Int32
    @NSManaged public var permalink: String?
    @NSManaged public var place: Int32
    @NSManaged public var size: Int64
    @NSManaged public var title_en: String?
    @NSManaged public var title_es: String?
    @NSManaged public var title_eu: String?
    @NSManaged public var uploaded: NSDate?
    @NSManaged public var username: String?
    @NSManaged public var width: Int32

}
