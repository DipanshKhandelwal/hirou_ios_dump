//
//  TaskCollection.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskCollection {
    //MARK: Properties
    var id: Int
    var timestamp: String
    var complete: Bool
    var amount: Int
    var garbage: Garbage
    var available: Bool
    var taskCollectionPoint: Int
    
    init?(id: Int, timestamp: String, complete: Bool, amount: Int, garbage: Garbage, available: Bool, taskCollectionPoint: Int) {
        // Initialize stored properties.
        self.id = id
        self.timestamp = timestamp
        self.complete = complete
        self.amount = amount
        self.garbage = garbage
        self.available = available
        self.taskCollectionPoint = taskCollectionPoint
    }
}
