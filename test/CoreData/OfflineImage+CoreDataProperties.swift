//
//  OfflineImage+CoreDataProperties.swift
//  test
//
//  Created by user184351 on 11/17/20.
//
//

import Foundation
import CoreData


extension OfflineImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OfflineImage> {
        return NSFetchRequest<OfflineImage>(entityName: "OfflineImage")
    }

    @NSManaged public var imagename: String?

}

extension OfflineImage : Identifiable {

}
