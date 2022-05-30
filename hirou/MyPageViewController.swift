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
        let confirmAlert = UIAlertController(title: "ログアウト ?", message: "ログアウトしてもよろしいですか？", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { (action: UIAlertAction!) in
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
    
    @IBAction func onEnquiryClicked(_ sender: Any) {
        openUrlInBrowser(url: Urls.CONTACT_US)
    }
    
    @IBAction func onPrivatePolicyClicked(_ sender: Any) {
        openUrlInBrowser(url: Urls.PRIVATE_POLICY)
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
