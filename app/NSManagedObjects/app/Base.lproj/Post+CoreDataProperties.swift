//
//  Post+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var comments: Int16
    @NSManaged public var dtime: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var permalink: String?
    @NSManaged public var text_en: String?
    @NSManaged public var text_es: String?
    @NSManaged public var text_eu: String?
    @NSManaged public var title_en: String?
    @NSManaged public var title_es: String?
    @NSManaged public var title_eu: String?
    @NSManaged public var username: String?

}
