//
//  APIHeaders.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 13/11/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import Alamofire

class APIHeaders {
    class func getHeaders() -> HTTPHeaders? {
        guard let token = UserDefaults.standard.string(forKey: UserDefaultsConstants.AUTH_TOKEN) else {
            print("AUTH_TOKEN not found")
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Token " + token]
        
        return headers
    }
}
