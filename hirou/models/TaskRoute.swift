//
//  TaskRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskRoute: Encodable, Decodable {
    //MARK: Properties
    var id: Int
    var name: String
    var customer: Customer?
    var date: Date
    var garbageList: [Garbage]
    var taskCollectionPoints: [TaskCollectionPoint]
    
    init?(id: Int, name : String, customer: Customer?, garbageList: [Garbage], date: Date, taskCollectionPoints: [TaskCollectionPoint]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.garbageList = garbageList
        self.date = date
        self.taskCollectionPoints = taskCollectionPoints
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case customer
        case date
        case garbageList = "garbage"
        case taskCollectionPoints = "task_collection_point"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        customer = try container.decodeIfPresent(Customer.self, forKey: .customer)
        garbageList = try container.decode([Garbage].self, forKey: .garbageList)
        taskCollectionPoints = try container.decode([TaskCollectionPoint].self, forKey: .taskCollectionPoints)
        let dateStr = try container.decode(String.self, forKey: .date)
        date = TaskRoute.getDateFromString(dateStr: dateStr)
    }
    
    static func getDateFromString(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter.date(from: dateStr)!
    }
    
    func getGarbagesNameList() -> String{
        var garbageSet : Set<String> = []
        var stringGarbageList = "Empty"
        for tcp in self.taskCollectionPoints {
            for tc in tcp.taskCollections {
                garbageSet.insert(tc.garbage.name)
            }
        }
        if(garbageSet.count > 0) {
            stringGarbageList = ""
        }
        for garbage in garbageSet {
            stringGarbageList += garbage + ", "
        }
        return stringGarbageList
    }
    
    func getCompleteStatus() -> Bool{
        var complete = true
        for tcp in self.taskCollectionPoints {
            for tc in tcp.taskCollections {
                if(tc.complete == false) {
                    complete = false
                    return complete
                }
            }
        }
        return complete
    }
    
}
