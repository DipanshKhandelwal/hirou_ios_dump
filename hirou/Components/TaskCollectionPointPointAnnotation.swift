//
//  TaskCollectionPointPointAnnotation.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 12/05/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import Mapbox

class TaskCollectionPointPointAnnotation: MGLPointAnnotation {
    var taskCollectionPoint: TaskCollectionPoint!
    
    init(taskCollectionPoint: TaskCollectionPoint) {
        super.init()
        self.taskCollectionPoint = taskCollectionPoint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
