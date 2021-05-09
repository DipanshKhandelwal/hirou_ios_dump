//
//  MainMenuViewController.swift
//  hirou
//
//  Created by 猪俣貴裕 on 2021/01/06.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        let confirmAlert = UIAlertController(title: "Logout ?", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Yes. Logout", style: .default, handler: { (action: UIAlertAction!) in
            self.logout()
        }))
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    func logout() {
        DispatchQueue.main.async {
            UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.USER_USERNAME)
            UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.USER_ID)
            UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.AUTH_TOKEN)
            UserDefaults.standard.synchronize()
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
}
