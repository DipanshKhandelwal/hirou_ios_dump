//
//  TaskReport.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct TaskReport : Encodable, Decodable{
    var id: Int
    var route: Int
    var taskCollectionPoint: Int?
    var reportType: ReportType
    var image: String?
    var timestamp: String?
    var description: String?
    
    init?(id: Int, route : Int, taskCollectionPoint: Int, timestamp: String, reportType: ReportType, image: String?, description: String?) {
        // Initialize stored properties.
        self.id = id
        self.route = route
        self.taskCollectionPoint = taskCollectionPoint
        self.reportType = reportType
        self.image = image
        self.timestamp = timestamp
        self.description = description
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case route
        case taskCollectionPoint = "task_collection_point"
        case reportType = "report_type"
        case image
        case timestamp
        case description
    }
}
