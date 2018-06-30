//
//  Post_image+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Post_image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post_image> {
        return NSFetchRequest<Post_image>(entityName: "Post_image")
    }

    @NSManaged public var id: Int32
    @NSManaged public var idx: Int16
    @NSManaged public var image: String?
    @NSManaged public var post: Int32

}
