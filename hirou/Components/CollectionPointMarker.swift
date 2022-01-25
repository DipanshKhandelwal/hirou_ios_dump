//
//  CollectionPointMarker.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 17/01/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import GoogleMaps

class CollectionPointMarker: GMSMarker {
    var collectionPoint: CollectionPoint!
    
    init(collectionPoint: CollectionPoint) {
        super.init()
        self.collectionPoint = collectionPoint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

