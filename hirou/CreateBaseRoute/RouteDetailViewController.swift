//
//  CreateRouteViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 13/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class RouteDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GarbageTypesViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var routeNameTextField: UITextField!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var customerPicker: UIPickerView!
    @IBOutlet weak var garbageListLabel: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var moveToRouteScreenButton: UIButton!
    @IBOutlet weak var routeErrorLabel: UILabel!
    
    var selectedCustomerId : Int?
    var selectedGarbages: [Garbage]! = []
    var customers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customerPicker.delegate = self
        self.customerPicker.dataSource = self
        self.customerPicker.isHidden = true
        
        self.routeNameTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(customerLabelPressed))
        customerLabel.addGestureRecognizer(tap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        configureView()
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.routeNameTextField.resignFirstResponder()
        customerPicker.isHidden = true
    }
    
    @objc
    func customerLabelPressed(sender: UITapGestureRecognizer) {
        self.routeNameTextField.resignFirstResponder()
        customerPicker.isHidden = !customerPicker.isHidden
    }
    
    func saveRouteCall() {
        var garbageTypes = [Int]()
        for gb in self.selectedGarbages {
            garbageTypes.append(gb.id)
        }
        
        let values = [
            "name": String(self.routeNameTextField.text!),
            "customer": self.selectedCustomerId,
            "garbage": garbageTypes
            ] as [String : Any?]
        
        if (detailItem != nil) {
            let id = UserDefaults.standard.string(forKey: "selectedRoute")!
            let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
            var request = URLRequest(url: try! url.asURL())
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            
            AF.request(request)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        } else {
            let url = Environment.SERVER_URL + "api/base_route/"
            var request = URLRequest(url: try! url.asURL())
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            
            AF.request(request)
                .response {
                    response in
                    switch response.result {
                    case .success( _):
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    func deleteRouteCall(){
        if detailItem != nil {
            let id = UserDefaults.standard.string(forKey: "selectedRoute")!
            AF.request(Environment.SERVER_URL + "api/base_route/"+String(id)+"/", method: .delete)
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
        if self.routeNameTextField.text!.count == 0 {
            let nameAlert = UIAlertController(title: "Route name empty !!", message: "Please enter name of the route.", preferredStyle: .alert)
            nameAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Please enter a name")
            }))
            self.present(nameAlert, animated: true, completion: nil)
        } else {
            saveRouteCall()
        }
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
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = self.routeNameTextField {
                label.text = (detail as! BaseRoute).name
            }
            if let label = self.customerLabel {
                label.text = (detail as! BaseRoute).customer?.name ?? "n/a"
            }
            self.selectedCustomerId = (detail as! BaseRoute).customer?.id
            self.selectedGarbages = (detail as! BaseRoute).garbageList
            setGarbageLabelValue()
            UserDefaults.standard.set((detail as! BaseRoute).id, forKey: "selectedRoute")
            if let routeErrorLabel = self.routeErrorLabel {
                routeErrorLabel.isHidden = true
            }
        } else {
            if let label = self.routeNameTextField {
                label.text = ""
            }
            
            if let label = self.customerLabel {
                label.text = "n/a"
            }
            
            if let label = self.garbageListLabel {
                label.text = ""
            }
            
            if let button = self.deleteButton {
                button.isEnabled = false
            }
            
            if let moveToRouteScreenButton = self.moveToRouteScreenButton {
                moveToRouteScreenButton.isEnabled = false
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
        AF.request(Environment.SERVER_URL + "api/customer/", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.customers = try! JSONDecoder().decode([Customer].self, from: value!)
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
    
    // text field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.routeNameTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.customerPicker.isHidden = true
    }

    // picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customers.count
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
        if segue.identifier == "selectGarbageTypes" {
            self.routeNameTextField.resignFirstResponder()
            customerPicker.isHidden = true
            
            let controller = (segue.destination as! GarbageTypesTableViewController)
            controller.delegate = self
            controller.detailItem = self.selectedGarbages
        }
    }
}
