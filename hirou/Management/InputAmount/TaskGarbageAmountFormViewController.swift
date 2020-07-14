//
//  InputAmountFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class TaskGarbageAmountFormViewController: UIViewController {

    var garbages = [Garbage]()
    @IBOutlet weak var garbageLabel: DisabledUITextField!
    @IBOutlet weak var amountLabel: DisabledUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.amountLabel.resignFirstResponder();
        self.garbageLabel.resignFirstResponder();
    }

    @IBAction func cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request(Environment.SERVER_URL + "api/garbage/", method: .get).response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.garbages = try! decoder.decode([Garbage].self, from: value!)
                DispatchQueue.main.async {
                    self.garbagePicker.reloadAllComponents()
                }
            case .failure(let error):
                print(error)
            }
        }
        super.viewWillAppear(animated)
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
