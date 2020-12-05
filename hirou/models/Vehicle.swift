//
//  Vehicle.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 12/02/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation

class Vehicle: Encodable, Decodable {
    var id: Int
    var registrationNumber: String
    var model : String
    
    init?(id: Int, registrationNumber : String, model: String) {
        // Initialization should fail if there is no registration number.
        if registrationNumber.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.id = id
        self.registrationNumber = registrationNumber
        self.model = model
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case model
        case registrationNumber = "registration_number"
    }
    
    static func getVehicleFromResponse(obj : AnyObject) -> Vehicle {
        let id = obj["id"] as! Int
        let registrationNumber = obj["registration_number"] as! String
        let model = obj["model"] as! String

//        let locationCoordinates = (obj["location"] as! String).split{$0 == ","}.map(String.init)
//        let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )!
//        let vehicleObj = Vehicle(id: id, registrationNumber: registrationNumber, model: model, location: location)
        let vehicleObj = Vehicle(id: id, registrationNumber: registrationNumber, model: model)
        return vehicleObj!
    }
}
