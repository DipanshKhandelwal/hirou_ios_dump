//
//  CreateRouteViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 13/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class CreateRouteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var customerPicker: UIPickerView!
    @IBOutlet weak var customerTextField: UITextField!
    @IBOutlet weak var routeNameTextField: UITextField!
    
    var customers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        customers = [ "1", "2", "3", "4", "5" ]
        self.customerPicker.delegate = self
        self.customerTextField.delegate = self
        self.customerPicker.dataSource = self
        
        self.customerPicker.isHidden = true
        if(self.customers.count > 0) {
            self.customerTextField.text = self.customers[0].name
        }
        
        // Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = self.routeNameTextField {
                label.text = (detail as! BaseRoute).name
            }
            
            if let label = self.customerTextField {
                label.text = (detail as! BaseRoute).customer
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request("http://127.0.0.1:8000/api/customer/", method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                //                print(String(data: value as! Data, encoding: .utf8)!)
                //                completion(try? SomeRequest(protobuf: value))
                //                        print("response", value)
                //                self.vehicles = value as! [Any]
                self.customers = []
                
                for customer in value as! [Any] {
                    //                            print("customer", customer)
                    
                    let name = ((customer as AnyObject)["name"] as! String)
                    let description = ((customer as AnyObject)["description"] as! String)
                    
                    let customerObj = Customer( name: name, description: description)
                    self.customers.append(customerObj!)
                    //                            self.customerPicker.reloadData()
                }
                
                self.customerPicker.reloadAllComponents()
                //                        if(self.customers.count > 0) {
                //                            self.customerTextField.text = self.customers[0].name
                //                        }
                
                //                        DispatchQueue.main.async {
                //                            self.tableView.reloadData()
                //                        }
                //                print("vehicles",self.vehicles)
            //                self.tableView.reloadData()
            case .failure(let error):
                print(error)
                //                completion(nil)
            }
            
        }
        
        super.viewWillAppear(animated)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customers.count
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return customers[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.customers.count >= row) {
            self.customerTextField.text = self.customers[row].name
        }
        self.customerPicker.isHidden = true
        self.customerTextField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.customerPicker.isHidden = false
        print("called")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.customerPicker.isHidden = false
        print("called 2")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.customerPicker.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.customerPicker.isHidden = false
        return true
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if segue.identifier == "showRouteDetails" {
            let controller = (segue.destination as! RouteDetailsViewController)
            if let detail = detailItem {
//                print("id", )
                controller.detailItem = (detail as! BaseRoute).id
            }
        }
        
     }

    
}
