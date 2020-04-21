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
    var customer: Customer
    var date: String
    
    init?(id: Int, name : String, customer: Customer, date: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.date = date
    }
}
