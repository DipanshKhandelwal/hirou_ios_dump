//
//  WebSocketConstants.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/04/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct SocketKeys {
    static let EVENT = "event"
    static let SUB_EVENT = "sub-event"
    static let DATA = "data"
}

struct WebSocketChannels {
    static let COLLECTION_POINT_CHANNEL = "collection-point-channel"
    static let TASK_COLLECTION_POINT_CHANNEL = "task-collection-point-channel"
}

struct SocketEventTypes {
    static let BASE_ROUTE = "base-route"
    static let COLLECTION_POINT = "collection-point"
    static let TASK_COLLECTION_POINT = "task-collection-point"
}

struct SocketSubEventTypes {
    static let REORDER = "reorder"
}

struct SocketUpdateTypes {
    static let SUBSCRIBE = "subscribe"
    static let UNSUBSCRIBE = "unsubscribe"
}
