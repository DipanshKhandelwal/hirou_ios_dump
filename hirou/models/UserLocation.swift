//
//  UserLocation.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 01/06/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct UserLocation : Encodable, Decodable{
    //MARK: Properties
    var id: Int
    var name: String
    var location: Location
    
    init?(id: Int, name : String, location: Location) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.location = location
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case location
    }
}
