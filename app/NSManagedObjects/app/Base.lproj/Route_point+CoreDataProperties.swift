//
//  Route_point+CoreDataProperties.swift
//  app
//
//  Created by Iñigo Valentin on 21/6/18.
//  Copyright © 2018 Margolariak. All rights reserved.
//
//

import Foundation
import CoreData


extension Route_point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route_point> {
        return NSFetchRequest<Route_point>(entityName: "Route_point")
    }

    @NSManaged public var id: Int32
    @NSManaged public var lat_d: Double
    @NSManaged public var lat_o: Double
    @NSManaged public var lon_d: Double
    @NSManaged public var lon_o: Double
    @NSManaged public var part: Int16
    @NSManaged public var place_d: Int32
    @NSManaged public var place_o: Int32
    @NSManaged public var route: Int32

}
