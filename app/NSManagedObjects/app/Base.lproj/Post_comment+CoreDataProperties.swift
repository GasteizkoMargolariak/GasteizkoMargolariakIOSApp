//
//  Post_comment+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Post_comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post_comment> {
        return NSFetchRequest<Post_comment>(entityName: "Post_comment")
    }

    @NSManaged public var dtime: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var lang: String?
    @NSManaged public var post: Int32
    @NSManaged public var text: String?
    @NSManaged public var username: String?

}
