//
//  CollectionPoint.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct CollectionPoint: Encodable, Decodable {
    //MARK: Properties
    var id: Int
    var name: String
    var address: String
    var route: Int
    var location: Location
    var sequence: Int
    var image: String?
    
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
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case address
        case route
        case sequence
        case image
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        route = try container.decode(Int.self, forKey: .route)
        sequence = try container.decode(Int.self, forKey: .sequence)
        location = try container.decode(Location.self, forKey: .location)
        image = (try container.decodeIfPresent(String.self, forKey: .image)) ?? ""
    }
}
