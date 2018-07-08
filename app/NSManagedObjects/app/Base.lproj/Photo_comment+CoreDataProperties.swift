//
//  Photo_comment+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo_comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo_comment> {
        return NSFetchRequest<Photo_comment>(entityName: "Photo_comment")
    }

    @NSManaged public var dtime: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var lang: String?
    @NSManaged public var photo: Int32
    @NSManaged public var text: String?
    @NSManaged public var username: String?

}
