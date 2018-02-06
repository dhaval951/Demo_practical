//
//  Product+CoreDataProperties.swift
//  Test_app
//
//  Created by Dhaval Bhadania on 31/01/18.
//  Copyright © 2018 Dhaval Bhadania. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var brand: String?
    @NSManaged public var created_at: String?
    @NSManaged public var productid: String?
    @NSManaged public var quantity: String?
    @NSManaged public var price: String?
    @NSManaged public var name: String?
    @NSManaged public var sku: String?
    @NSManaged public var updated_at: String?

}
