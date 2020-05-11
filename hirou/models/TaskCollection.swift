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
    var timestamp: String
    var complete: Bool
    var amount: Int
    var garbage: Garbage
    var available: Bool
    
    init?(id: Int, timestamp: String, complete: Bool, amount: Int, garbage: Garbage, available: Bool) {
        // Initialize stored properties.
        self.id = id
        self.timestamp = timestamp
        self.complete = complete
        self.amount = amount
        self.garbage = garbage
        self.available = available
    }
    
    static func getTaskCollectionFromResponse(obj : AnyObject) -> TaskCollection {
        let id = obj["id"] as! Int
        let timestamp = obj["timestamp"] as! String
        let complete = obj["complete"] as! Bool
        let amount = obj["amount"] as! Int
        
        let garbageResponse = obj["garbage"] as AnyObject
        let garbage = Garbage.getGarbageFromResponse(obj: garbageResponse)
        
        let available = obj["available"] as! Bool
        
        let taskCollectionObj = TaskCollection(id: id, timestamp: timestamp, complete: complete, amount: amount, garbage: garbage, available: available)
        return taskCollectionObj!
    }
}
