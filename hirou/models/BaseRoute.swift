//
//  BaseRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct BaseRoute : Encodable, Decodable{
    
    //MARK: Properties
    var id: Int
    var name: String
    var customer: Customer?
    var garbageList: [Garbage]
    var collectionPoints: [CollectionPoint]
    
    init?(id: Int, name : String, customer: Customer?, garbageList: [Garbage], collectionPoints: [CollectionPoint]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.garbageList = garbageList
        self.collectionPoints = collectionPoints
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case customer
        case garbageList = "garbage"
        case collectionPoints = "collection_point"
    }
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        garbageList = try container.decode([Garbage].self, forKey: .garbageList)
        collectionPoints = try container.decode([CollectionPoint].self, forKey: .collectionPoints)
        customer = try container.decodeIfPresent(Customer.self, forKey: .customer)
    }

    func getGarbagesNameList() -> String {
        return self.garbageList.map(){ String($0.name) }.joined(separator: ", ")
    }
}
