//
//  TaskCollectionPoint.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskCollectionPoint : Encodable, Decodable{
    //MARK: Properties
    var id: Int
    var name: String
    var address: String
    var location: Location
    var taskRoute: Int
    var sequence: Int
    var image: String
    var taskCollections: [TaskCollection]
    
    init?(id: Int, name : String, address: String, location: Location, sequence: Int, taskRoute: Int, image: String, taskCollections: [TaskCollection]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.address = address
        self.taskRoute = taskRoute
        self.location = location
        self.sequence = sequence
        self.image = image
        self.taskCollections = taskCollections
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case address
        case taskRoute = "route"
        case location
        case sequence
        case image
        case taskCollections = "task_collection"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        taskRoute = try container.decode(Int.self, forKey: .taskRoute)
        address = try container.decode(String.self, forKey: .address)
        sequence = try container.decode(Int.self, forKey: .sequence)
        location = try container.decode(Location.self, forKey: .location)
        taskCollections = try container.decode([TaskCollection].self, forKey: .taskCollections)
        image = (try container.decodeIfPresent(String.self, forKey: .image)) ?? ""
    }
}
