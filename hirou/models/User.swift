//
//  User.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 13/11/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct User : Encodable, Decodable{
    var id: Int
    var email: String?
    var username: String?
    var first_name: String?
    var last_name: String?

    init?(id: Int, email: String?, username: String?, first_name: String?, last_name: String?) {
        self.id = id
        self.email = email
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case email
        case username
        case first_name
        case last_name
    }
}
