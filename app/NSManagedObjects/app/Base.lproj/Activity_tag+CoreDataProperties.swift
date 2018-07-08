//
//  Activity_tag+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity_tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity_tag> {
        return NSFetchRequest<Activity_tag>(entityName: "Activity_tag")
    }

    @NSManaged public var activity: Int32
    @NSManaged public var tag: String?

}
