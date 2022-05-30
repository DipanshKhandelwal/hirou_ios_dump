//
//  TaskCollection.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskCollection : Encodable, Decodable{
    //MARK: Properties
    var id: Int
    var timestamp: String?
    var complete: Bool
    var amount: Int
    var garbage: Garbage
    var available: Bool
    var users: User?
    
    init?(id: Int, timestamp: String, complete: Bool, amount: Int, garbage: Garbage, user: User?, available: Bool) {
        // Initialize stored properties.
        self.id = id
        self.timestamp = timestamp
        self.complete = complete
        self.amount = amount
        self.garbage = garbage
        self.available = available
        self.users = user
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case timestamp
        case complete
        case amount
        case garbage
        case available
        case users
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        timestamp = (try container.decodeIfPresent(String.self, forKey: .timestamp))
        complete = try container.decode(Bool.self, forKey: .complete)
        amount = try container.decode(Int.self, forKey: .amount)
        garbage = try container.decode(Garbage.self, forKey: .garbage)
        available = try container.decode(Bool.self, forKey: .available)
        users = try? container.decode(User.self, forKey: .users)
    }
}
