//
//  Customer.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 14/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Customer : Encodable, Decodable{
    //MARK: Properties
    var id: Int
    var name: String
    var description : String = ""
    
    init?(name : String, description: String, id: Int) {
        // Initialization should fail if there is no name.
        if name.isEmpty  {
            return nil
        }
        // Initialize stored properties.
        self.name = name
        self.id = id
        self.description = description
    }

    enum CodingKeys : String, CodingKey {
        case id
        case name
        case description
    }
    
    static func getCustomerFromResponse(obj : AnyObject) -> Customer {
        let customerName = obj["name"] as! String
        let customerId = obj["id"] as! Int
        let customerDes = obj["description"] as! String
        
        let customerObj = Customer(name: customerName, description: customerDes, id: customerId)
        return customerObj!
    }
}
