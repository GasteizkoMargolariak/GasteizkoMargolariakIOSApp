//
//  Activity_image+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity_image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity_image> {
        return NSFetchRequest<Activity_image>(entityName: "Activity_image")
    }

    @NSManaged public var activity: Int32
    @NSManaged public var id: Int32
    @NSManaged public var idx: Int16
    @NSManaged public var image: String?

}
