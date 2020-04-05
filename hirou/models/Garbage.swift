//
//  Garbage.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 06/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Garbage {
    //MARK: Properties
    var id: Int
    var name: String
    var description: String
    
    init?(id: Int, name : String, description: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.description = description
    }
}
