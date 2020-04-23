//
//  TaskRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskRoute {
    //MARK: Properties
    var id: Int
    var name: String
    var customer: Customer
    var date: String
    var taskCollectionPoints: [TaskCollectionPoint]
    
    init?(id: Int, name : String, customer: Customer, date: String, taskCollectionPoints: [TaskCollectionPoint]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.date = date
        self.taskCollectionPoints = taskCollectionPoints
    }
    
    static func getTaskRouteFromResponse(obj: AnyObject) -> TaskRoute{
        let id = obj["id"] as! Int
        let name = obj["name"] as! String
        
        let customerResponse = obj["customer"] as AnyObject
        let customer = Customer.getCustomerFromResponse(obj: customerResponse)
        
        let date = obj["date"] as! String
        
        var taskCollectionPoints = [TaskCollectionPoint]()
        let taskCollectionPointsResponse = obj["task_collection_point"] as AnyObject
        for tc in taskCollectionPointsResponse as! [Any] {
            let taskCollectionPointResponse = (tc as AnyObject)
            let taskCollectionPoint = TaskCollectionPoint.getTaskCollectionPointFromResponse(obj: taskCollectionPointResponse)
            taskCollectionPoints.append(taskCollectionPoint)
        }

        let taskRouteObj = TaskRoute(id: id, name: name, customer: customer, date: date, taskCollectionPoints: taskCollectionPoints)
        return taskRouteObj!
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
