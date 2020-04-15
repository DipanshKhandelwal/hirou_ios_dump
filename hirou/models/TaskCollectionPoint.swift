//
//  TaskCollectionPoint.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskCollectionPoint {
    //MARK: Properties
    var id: Int
    var name: String
    var address: String
    var taskRoute: Int
    var location: Location
    var sequence: Int
    var image: String

    init?(id: Int, name : String, address: String, taskRoute: Int, location: Location, sequence: Int, image: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.address = address
        self.taskRoute = taskRoute
        self.location = location
        self.sequence = sequence
        self.image = image
    }
}
