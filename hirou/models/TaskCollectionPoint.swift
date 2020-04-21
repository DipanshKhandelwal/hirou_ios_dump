//
//  TaskCollectionPoint.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 15/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class TaskCollectionPoint {
    //MARK: Properties
    var id: Int
    var name: String
    var address: String
    var location: Location
    var sequence: Int
    var image: String
    var taskCollections: [TaskCollection]

    init?(id: Int, name : String, address: String, location: Location, sequence: Int, image: String, taskCollections: [TaskCollection]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.sequence = sequence
        self.image = image
        self.taskCollections = taskCollections
    }
    
    static func getTaskCollectionPointFromResponse(obj : AnyObject) -> TaskCollectionPoint {
        let name = obj["name"] as! String
        let id = obj["id"] as! Int
        let address = obj["address"] as! String
        
        let locationCoordinates = (obj["location"] as! String).split{$0 == ","}.map(String.init)
        let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )

        let sequence = obj["sequence"] as! Int
        
        let image = ""
        
        var taskCollections = [TaskCollection]()
        let taskCollectionsResponse = obj["task_collection"] as AnyObject
        for tc in taskCollectionsResponse as! [Any] {
            let taskCollectionResponse = (tc as AnyObject)
            let taskCollection = TaskCollection.getTaskCollectionFromResponse(obj: taskCollectionResponse)
            taskCollections.append(taskCollection)
        }

        let taskCollectionPointObj = TaskCollectionPoint(id: id, name: name, address: address, location: location, sequence: sequence, image: image, taskCollections: taskCollections);
        return taskCollectionPointObj!
    }
}
