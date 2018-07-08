//
//  Photo_album+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo_album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo_album> {
        return NSFetchRequest<Photo_album>(entityName: "Photo_album")
    }

    @NSManaged public var album: Int32
    @NSManaged public var photo: Int32

}
