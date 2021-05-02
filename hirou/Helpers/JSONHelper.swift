//
//  JSONHelper.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/04/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func jsonToNSData(json: Any) -> Data?{
    do {
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil;
}
