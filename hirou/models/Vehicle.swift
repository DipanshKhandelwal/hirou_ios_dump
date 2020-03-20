//
//  Vehicle.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 12/02/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Vehicle {
    //MARK: Properties
    var registrationNumber: String = ""
    var model : String = ""
    var location : Location?
    var users: [String] = []
    
    init?(registrationNumber : String, model: String, location: Location, users: [String]) {
        // Initialization should fail if there is no registration number.
        if registrationNumber.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.registrationNumber = registrationNumber
        self.model = model
        self.location = location
        self.users = users
    }
}
