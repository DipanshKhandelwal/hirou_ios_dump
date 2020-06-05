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
    @IBOutlet weak var dateLabel: UILabel!
    
    var baseRoutes = [BaseRoute]()
    var customerPicker = UIPickerView()
    var selectedBaseRoute: BaseRoute?
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomerPicker()
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            if let detail = detailItem {
                let date = detail as! Date
                self.date = date
                print("date", date)
                configureView()
            }
        }
    }
    
    func configureView()  {
        
    }
    
    @IBAction func cancelAddTask(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewTask(_ sender: Any) {
        if selectedBaseRoute == nil {
            let deleteAlert = UIAlertController(title: "Please select a base route !!", message: "", preferredStyle: .alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            return
        } else {
            addNewTask()
        }
    }
    
    func addNewTask () {
        let routeId = selectedBaseRoute?.id
        let parameters: [String: String] = [
            "name": String(self.taskName.text!),
            "id": String(routeId!)
        ]
        AF.request("http://127.0.0.1:8000/api/task_route/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    print("value", value)
                    _ = self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print(error)
                }
        }
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
