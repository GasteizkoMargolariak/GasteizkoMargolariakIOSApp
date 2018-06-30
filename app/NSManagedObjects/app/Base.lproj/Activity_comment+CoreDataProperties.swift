//
//  Activity_comment+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity_comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity_comment> {
        return NSFetchRequest<Activity_comment>(entityName: "Activity_comment")
    }

    @NSManaged public var activity: Int32
    @NSManaged public var dtime: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var lang: String?
    @NSManaged public var text: String?
    @NSManaged public var username: String?

}
