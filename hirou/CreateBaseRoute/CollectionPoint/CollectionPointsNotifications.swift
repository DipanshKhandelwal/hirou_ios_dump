//
//  CollectionPointsNotifications.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var CollectionPointsTableSelect: Notification.Name {
        return .init(rawValue: "CollectionPoints.Select.Table")
    }
    
    static var CollectionPointsTableReorder: Notification.Name {
        return .init(rawValue: "CollectionPoints.Reorder.Table")
    }

    static var CollectionPointsMapSelect: Notification.Name {
        return .init(rawValue: "CollectionPoints.Select.Map")
    }
}
