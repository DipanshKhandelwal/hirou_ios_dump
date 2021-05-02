//
//  WebSocketProtocol.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/04/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation

protocol WebSocketProtocol {
    func send(message : String)
    func send(data : Data)
    func establishConnection()
    func disconnect()
}
