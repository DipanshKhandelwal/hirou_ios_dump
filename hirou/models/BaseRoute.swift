//
//  BaseRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class BaseRoute {
    //MARK: Properties
    var id: Int
    var name: String
    var customer: String
    
    init?(id: Int, name : String, customer: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
    }
}
