//
//  MyPageViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 11/10/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class MyPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: Any) {
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
        self.performSegue(withIdentifier: "myPageLogoutSegue", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
