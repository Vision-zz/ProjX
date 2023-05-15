//
//  FilterOptions+CoreDataProperties.swift
//  ProjX
//
//  Created by Sathya on 09/05/23.
//
//

import Foundation
import CoreData


extension FilterOptions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilterOptions> {
        return NSFetchRequest<FilterOptions>(entityName: "FilterOptions")
    }

    @NSManaged public var groupAndSortByString: String?
    @NSManaged public var filtersString: String?
    @NSManaged public var user: User?

}

extension FilterOptions : Identifiable {

}
