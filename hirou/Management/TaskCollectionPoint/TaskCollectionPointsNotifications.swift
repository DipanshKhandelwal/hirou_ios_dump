//
//  CollectionPointsNotifications.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var CollectionPointsHListUpdate: Notification.Name {
        return .init(rawValue: "CollectionPoints.Update.HList")
    }
    
    static var CollectionPointsVListUpdate: Notification.Name {
        return .init(rawValue: "CollectionPoints.Update.VList")
    }
    
    static var CollectionPointsHListSelect: Notification.Name {
        return .init(rawValue: "CollectionPoints.Select.VList")
    }
}
