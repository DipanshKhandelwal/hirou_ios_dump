//
//  TaskAddViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 29/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var routeLabel: DisabledUITextField!
    
    var baseRoutes = [BaseRoute]()
    var customerPicker = UIPickerView()
    var selectedBaseRoute: BaseRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomerPicker()
    }

    @IBAction func cancelAddTask(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request("http://127.0.0.1:8000/api/base_route/", method: .get).response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.baseRoutes = try! decoder.decode([BaseRoute].self, from: value!)
                DispatchQueue.main.async {
                    self.customerPicker.reloadAllComponents()
                }
            case .failure(let error):
                print(error)
            }
        }
        super.viewWillAppear(animated)
    }

    
    // picker
    
    func setupCustomerPicker() {
        customerPicker.backgroundColor = UIColor.white

        customerPicker.delegate = self
        customerPicker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.pickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        routeLabel.inputView = customerPicker
        routeLabel.inputAccessoryView = toolBar
    }
    
    @objc
    func pickerDone() {
        routeLabel.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return baseRoutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return baseRoutes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let route = self.baseRoutes[row]
        self.selectedBaseRoute = route
        self.routeLabel.text = route.name
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
