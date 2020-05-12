//
//  Location.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 14/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct Location : Encodable, Decodable{
    var latitude: String = "";
    var longitude: String = "";
    
    init?(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }

    enum CodingKeys : String, CodingKey {
        case latitude
        case longitude
    }

    init(from decoder: Decoder) throws{
        let container = try decoder.singleValueContainer()
        let locationString = try container.decode(String.self)
        let locationCoordinates = locationString.split{$0 == ","}.map(String.init)
        latitude = locationCoordinates[0]
        longitude = locationCoordinates[1]
    }
}
