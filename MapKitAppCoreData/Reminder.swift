//
//  Reminder.swift
//  MapKitAppCoreData
//
//  Created by Jeff Gayle on 8/20/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var message: String

}
