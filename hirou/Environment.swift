//
//  Environment.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 09/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

struct Environment {
//    static private var URL = "127.0.0.1:8000"
    static private var URL = "18.191.207.99"
    
    static let SERVER_URL = "http://" + URL + "/"
    static let SERVER_SOCKET_URL = "ws://" + URL + "/ws/"
}
