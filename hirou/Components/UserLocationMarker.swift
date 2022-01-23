//
//  UserLocationMarker.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/01/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import GoogleMaps

class UserLocationMarker: GMSMarker {
    var userLocation: UserLocation!
    
    init(userLocation: UserLocation) {
        super.init()
        self.userLocation = userLocation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

