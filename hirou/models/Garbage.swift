//
//  Garbage.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 06/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit

struct Garbage : Encodable, Decodable{
    //MARK: Properties
    var id: Int
    var name: String
    var description: String
    var customButton: CustomButton? {
        return CustomButton(rawValue: name)
    }
    
    init?(id: Int, name : String, description: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.description = description
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case description
    }
    
    static func getGarbageFromResponse(obj : AnyObject) -> Garbage {
        let id = obj["id"] as! Int
        let name = obj["name"] as! String
        let description = obj["description"] as! String
        let garbageObj = Garbage(id: id, name: name, description: description)
        return garbageObj!
    }
    
    enum CustomButton: String {
        case book = "雑誌"
        case can = "びん・缶・乾電池"
        case bottle = "ペットボトル"
        case milkBottle = "牛乳パック"
        case box = "ダンボール"
        case chemistry = "し尿"
        case newspaper = "新聞紙"
        case fabric = "古布"
        
        var iconActive: UIImage? {
            switch self {
            case .book:
                return UIImage(named: "ic_book_active")
            case .can:
                return UIImage(named: "ic_can_active")
            case .bottle:
                return UIImage(named: "ic_bottle_active")
            case .milkBottle:
                return UIImage(named: "ic_milkbottle_active")
            case .box:
                return UIImage(named: "ic_box_active")
            case .chemistry:
                return UIImage(named: "ic_chemistry_active")
            case .newspaper:
                return UIImage(named: "ic_newspaper_active")
            case .fabric:
                return UIImage(named: "ic_fabric_active")
            }
        }
        
        var iconInactive: UIImage? {
            switch self {
            case .book:
                return UIImage(named: "ic_book_inactive")
            case .can:
                return UIImage(named: "ic_can_inactive")
            case .bottle:
                return UIImage(named: "ic_bottle_inactive")
            case .milkBottle:
                return UIImage(named: "ic_milkbottle_inactive")
            case .box:
                return UIImage(named: "ic_box_inactive")
            case .chemistry:
                return UIImage(named: "ic_chemistry_inactive")
            case .newspaper:
                return UIImage(named: "ic_newspaper_inactive")
            case .fabric:
                return UIImage(named: "ic_fabric_inactive")
            }
        }
        var iconLine: UIImage? {
            switch self {
            case .book:
                return UIImage(named: "ic_book_line")
            case .can:
                return UIImage(named: "ic_can_line")
            case .bottle:
                return UIImage(named: "ic_bottle_line")
            case .milkBottle:
                return UIImage(named: "ic_milkbottle_line")
            case .box:
                return UIImage(named: "ic_box_line")
            case .chemistry:
                return UIImage(named: "ic_chemistry_line")
            case .newspaper:
                return UIImage(named: "ic_newspaper_line")
            case .fabric:
                return UIImage(named: "ic_fabric_line")
            }
        }
        var color: UIColor {
            switch self {
            case .book:
                return UIColor(0x3FB96D)
            case .can:
                return UIColor(0xF4CC61)
            case .bottle:
                return UIColor(0x4980CE)
            case .milkBottle:
                return UIColor(0x5DBBE8)
            case .box:
                return UIColor(0x5ED1B8)
            case .chemistry:
                return UIColor(0xAA62D8)
            case .newspaper:
                return UIColor(0x9BEB5E)
            case .fabric:
                return UIColor(0xFD7A49)
            }
        }
    }
}

extension UIColor {
    convenience init(_ hex: Int) {
        self.init(
            red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((hex & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((hex & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
}
