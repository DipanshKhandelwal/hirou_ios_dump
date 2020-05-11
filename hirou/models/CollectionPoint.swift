//
//  CollectionPoint.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class CollectionPoint: Encodable, Decodable {
    //MARK: Properties
    var id: Int
    var name: String
    var address: String
    var route: Int
    var location: Location
    var sequence: Int
    var image: String
    
    init?(id: Int, name : String, address: String, route: Int, location: Location, sequence: Int, image: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.address = address
        self.route = route
        self.location = location
        self.sequence = sequence
        self.image = image
    }
}
