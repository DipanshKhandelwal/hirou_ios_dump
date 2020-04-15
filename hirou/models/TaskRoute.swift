//
//  TaskRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskRoute {
    //MARK: Properties
    var id: Int
    var name: String
    var customer: Int
    var date: String
    var garbageList: [Garbage]
    
    init?(id: Int, name : String, customer: Int, date: String, garbageList: [Garbage]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.date = date
        self.garbageList = garbageList
    }
}
