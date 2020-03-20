//
//  Customer.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 14/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Customer {
    //MARK: Properties
    var name: String
    var description : String = ""
    
    init?(name : String, description: String) {
        // Initialization should fail if there is no name.
        if name.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.description = description
    }
}
