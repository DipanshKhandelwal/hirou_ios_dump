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
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: UserDefaultsConstants.AUTH_TOKEN) != nil {
            self.performSegue(withIdentifier: "loginSuccessfulSegue", sender: self)
        }
    }
    
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
                let addAlert = UIAlertController(title: "Error in logging in", message: "Please check credentials", preferredStyle: .alert)
                addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
                self.present(addAlert, animated: true, completion: nil)
                return
                
            case .success(let data):
                print("logged in", data)
                // First make sure you got back a dictionary if that's what you expect
                guard let json = data as? [String : AnyObject] else {
                    return
                }
                
                if let token = json["key"] {
                    UserDefaults.standard.set(token, forKey: UserDefaultsConstants.AUTH_TOKEN)
                    self.performSegue(withIdentifier: "loginSuccessfulSegue", sender: self)
                }
                else {
                    let addAlert = UIAlertController(title: "Error getting token", message: "Try again", preferredStyle: .alert)
                    addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
                    self.present(addAlert, animated: true, completion: nil)

                }
            }
        }
    }
}
