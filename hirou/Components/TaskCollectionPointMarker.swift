//
//  TaskCollectionPointMarker.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 19/01/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import GoogleMaps

class TaskCollectionPointMarker: GMSMarker {
    var taskCollectionPoint: TaskCollectionPoint!
    
    init(taskCollectionPoint: TaskCollectionPoint) {
        super.init()
        self.taskCollectionPoint = taskCollectionPoint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

