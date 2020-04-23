//
//  BaseRoute.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class BaseRoute {
    //MARK: Properties
    var id: Int
    var name: String
    var customer: Int
    var garbageList: [Garbage]
    
    init?(id: Int, name : String, customer: Int, garbageList: [Garbage]) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.customer = customer
        self.garbageList = garbageList
    }
    
    func getGarbagesNameList() -> String {
        var stringGarbageList = ""
        for garbage in self.garbageList {
            stringGarbageList += garbage.name + ", "
        }
        return stringGarbageList
    }
}
