//
//  SortEntity+CoreDataProperties.swift
//  StDevTask
//
//  Created by Developer on 03/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//
//

import Foundation
import CoreData


extension SortEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SortEntity> {
        return NSFetchRequest<SortEntity>(entityName: "SortEntity")
    }

    @NSManaged public var urlArray: [String]?
    @NSManaged public var sortType: String?

}
