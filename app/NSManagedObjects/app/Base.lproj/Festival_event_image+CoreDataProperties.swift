//
//  Festival_event_image+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Festival_event_image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Festival_event_image> {
        return NSFetchRequest<Festival_event_image>(entityName: "Festival_event_image")
    }

    @NSManaged public var event: Int32
    @NSManaged public var id: Int32
    @NSManaged public var idx: Int16
    @NSManaged public var image: String?

}
