//
//  Post_tag+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Post_tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post_tag> {
        return NSFetchRequest<Post_tag>(entityName: "Post_tag")
    }

    @NSManaged public var post: Int32
    @NSManaged public var tag: String?

}
