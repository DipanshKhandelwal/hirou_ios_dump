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
    var collectionPoint: Int
    var reportType: ReportType
    var image: String?
    
    init?(id: Int, route : Int, collectionPoint: Int, reportType: ReportType, image: String?) {
        // Initialize stored properties.
        self.id = id
        self.route = route
        self.collectionPoint = collectionPoint
        self.reportType = reportType
        self.image = image
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case route
        case collectionPoint = "collection_point"
        case reportType = "report_type"
        case image
    }
}