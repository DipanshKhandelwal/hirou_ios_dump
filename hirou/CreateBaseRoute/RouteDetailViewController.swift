//
//  CreateRouteViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 13/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class RouteDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GarbageTypesViewControllerDelegate {
    
    @IBOutlet weak var routeNameTextField: UITextField!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var customerPicker: UIPickerView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var garbageListLabel: UILabel!
    var selectedCustomerId : Int! = 0
    var newRoute : BaseRoute!
    var selectedGarbages: [Garbage]!
    var customers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customerPicker.delegate = self
        self.customerPicker.dataSource = self
        self.customerPicker.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(customerLabelPressed))
        customerLabel.addGestureRecognizer(tap)
        
        configureView()
    }
    
    @objc
    func customerLabelPressed(sender: UITapGestureRecognizer) {
        customerPicker.isHidden = !customerPicker.isHidden
    }
    
    func saveRouteCall() {
        if (detailItem != nil) {
            let id = UserDefaults.standard.string(forKey: "selectedRoute")!
            var garbageTypes = [Int]()
            for gb in self.selectedGarbages {
                garbageTypes.append(gb.id)
            }
            
            let url = "http://127.0.0.1:8000/api/base_route/"+String(id)+"/"
            var request = URLRequest(url: try! url.asURL())
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let values = [
                "name": String(self.routeNameTextField.text!),
                "customer": String(self.selectedCustomerId),
                "garbage": garbageTypes
                ] as [String : Any]
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            
            AF.request(request)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        } else {
            let parameters: [String: String] = [
                "name": String(self.routeNameTextField.text!),
            ]
            AF.request("http://127.0.0.1:8000/api/base_route/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .response {
                    response in
                    switch response.result {
                    case .success(let value):
                        let decoder = JSONDecoder()
                        self.newRoute = try! decoder.decode(BaseRoute.self, from: value!)
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }

    func deleteRouteCall(){
        if detailItem != nil {
            let id = UserDefaults.standard.string(forKey: "selectedRoute")!
            AF.request("http://127.0.0.1:8000/api/base_route/"+String(id)+"/", method: .delete)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        //                        self.customers = []
                        
                    case .failure(let error):
                        print(error)
                        //                completion(nil)
                    }
            }
        }
    }
    
    @IBAction func saveRoute(_ sender: Any) {
        saveRouteCall()
    }
    
    @IBAction func deleteRoute(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Route ?", message: "Are you sure you want to delete the base route ?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes. Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteRouteCall()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
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
            if let label = self.customerLabel {
                label.text = String((detail as! BaseRoute).customer)
            }
            self.selectedCustomerId = (detail as! BaseRoute).customer
            self.selectedGarbages = (detail as! BaseRoute).garbageList
            setGarbageLabelValue()
            UserDefaults.standard.set((detail as! BaseRoute).id, forKey: "selectedRoute")
        } else {
            if let label = self.customerLabel {
                label.text = ""
            }
            
            if let button = self.deleteButton {
                button.isHidden = true
            }
        }
    }
    
    func setGarbageLabelValue() {
        if let label = self.garbageListLabel {
            let garbageList = self.selectedGarbages!
            var stringGarbageList = ""
            for garbage in garbageList {
                stringGarbageList += garbage.name + ", "
            }
            label.text = stringGarbageList
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request("http://127.0.0.1:8000/api/customer/", method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.customers = []
                for customer in value as! [Any] {
                    let name = ((customer as AnyObject)["name"] as! String)
                    let description = ((customer as AnyObject)["description"] as! String)
                    let id = ((customer as AnyObject)["id"] as! Int)
                    let customerObj = Customer( name: name, description: description, id: id)
                    self.customers.append(customerObj!)
                }
                
                if (self.detailItem != nil) {
                    let id = UserDefaults.standard.string(forKey: "selectedRoute")!
                    for customer in self.customers {
                        if id == String(customer.id) {
                            if let label = self.customerLabel {
                                label.text = customer.name
                            }
                        }
                    }
                }
                self.customerPicker.reloadAllComponents()
                
            case .failure(let error):
                print(error)
            }
            
        }
        
        super.viewWillAppear(animated)
    }
    
    func setSelectedGarbage(selectedGarbageList: [Garbage]) {
        self.selectedGarbages = selectedGarbageList
        setGarbageLabelValue()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customers.count
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if(self.customers.count >= row) {
            return self.customers[row].name
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.customers.count >= row) {
            self.customerLabel.text = self.customers[row].name
            self.selectedCustomerId = self.customers[row].id
        }
        self.customerPicker.isHidden = true
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "selectGarbageTypes" {
            let controller = (segue.destination as! GarbageTypesTableViewController)
            controller.delegate = self
            controller.detailItem = self.selectedGarbages
        }
    }
}
