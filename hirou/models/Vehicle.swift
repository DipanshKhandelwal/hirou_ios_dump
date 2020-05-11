//
//  Vehicle.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 12/02/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Vehicle: Encodable, Decodable {
    //MARK: Properties
    var id: Int
    var registrationNumber: String
    var model : String
    var location : Location
    
    init?(id: Int, registrationNumber : String, model: String, location: Location) {
        // Initialization should fail if there is no registration number.
        if registrationNumber.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.id = id
        self.registrationNumber = registrationNumber
        self.model = model
        self.location = location
    }
    
    static func getVehicleFromResponse(obj : AnyObject) -> Vehicle {
        let id = obj["id"] as! Int
        let registrationNumber = obj["registration_number"] as! String
        let model = obj["model"] as! String
        
        let locationCoordinates = (obj["location"] as! String).split{$0 == ","}.map(String.init)
        let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )
        let vehicleObj = Vehicle(id: id, registrationNumber: registrationNumber, model: model, location: location)
        return vehicleObj!
    }
}
