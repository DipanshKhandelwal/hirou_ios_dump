//
//  CollectionPointsNotifications.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var TaskCollectionPointsHListUpdate: Notification.Name {
        return .init(rawValue: "TaskCollectionPoints.Update.HList")
    }
    
    static var TaskCollectionPointsVListUpdate: Notification.Name {
        return .init(rawValue: "TaskCollectionPoints.Update.VList")
    }
    
    static var TaskCollectionPointsHListSelect: Notification.Name {
        return .init(rawValue: "TaskCollectionPoints.Select.VList")
    }
    
    static var TaskCollectionPointsMapSelect: Notification.Name {
        return .init(rawValue: "TaskCollectionPoints.Select.Map")
    }
}
