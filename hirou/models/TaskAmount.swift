//
//  TaskAmount.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct TaskAmount : Encodable, Decodable{
    var id: Int
    var route: Int
    var garbage: Garbage
    var vehicle: Vehicle?
    var amount: Int
    var user: User?
    var memo: String = ""
    
    init?(id: Int, route : Int, garbage: Garbage, vehicle: Vehicle, amount: Int, user: User, memo: String) {
        // Initialize stored properties.
        self.id = id
        self.route = route
        self.garbage = garbage
        self.vehicle = vehicle
        self.amount = amount
        self.user = user
        self.memo = memo
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case route
        case garbage
        case vehicle
        case amount
        case user
        case memo
    }
}
