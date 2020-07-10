//
//  ReportType.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct ReportType : Encodable, Decodable{
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
}
