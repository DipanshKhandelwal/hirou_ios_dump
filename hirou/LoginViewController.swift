//
//  LoginViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let user = username.text, let pass = password.text else {
            print("LoginScreen::error getting username and password")
            return
        }
        
        let parameters = ["username": user, "password": pass]
        
        AF.request(Environment.SERVER_URL + "rest-auth/login/", method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                print("error: logging in", error)
                return
                
            case .success(let data):
                print("data", data)
                // First make sure you got back a dictionary if that's what you expect
                guard let json = data as? [String : AnyObject] else {
                    return
                }
                UserDefaults.standard.set(json["key"], forKey: UserDefaultsConstants.AUTH_TOKEN)
            }
        }
    }
}
