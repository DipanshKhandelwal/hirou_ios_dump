//
//  Garbage.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 06/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct Garbage : Encodable, Decodable{
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

    enum CodingKeys : String, CodingKey {
        case id
        case name
        case description
    }

    static func getGarbageFromResponse(obj : AnyObject) -> Garbage {
        let id = obj["id"] as! Int
        let name = obj["name"] as! String
        let description = obj["description"] as! String
        let garbageObj = Garbage(id: id, name: name, description: description)
        return garbageObj!
    }
    
}
