//
//  InputAmountFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskGarbageAmountFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var garbages = [Garbage]()
    var selectedGarbage: Garbage?
    
    var vehicles = [Vehicle]()
    var selectedVehicle: Vehicle?
    
    var garbagePicker = UIPickerView() // tag = 1
    var vehiclePicker = UIPickerView() // tag = 2

    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var taskAmount: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBOutlet weak var garbageLabel: DisabledUITextField!
    @IBOutlet weak var amountLabel: DisabledUITextField! // tag = 1
    @IBOutlet weak var vehicleLabel: DisabledUITextField!
    @IBOutlet weak var memoLabel: UITextField! // tag = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickers()
        
        amountLabel.delegate = self
        amountLabel.tag = 1
        
        memoLabel.delegate = self
        memoLabel.tag = 2
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.deleteButton?.isEnabled = false
        
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(saveClicked))
        navigationItem.setRightBarButton(saveButton, animated: true)

        fetchVehicles()
        
        configureView()
    }
    
    func fetchVehicles() {
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/vehicle/", method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.vehicles = try! decoder.decode([Vehicle].self, from: value!)
                DispatchQueue.main.async {
                    self.vehiclePicker.reloadAllComponents()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func setupPickers() {
        setupGarbagePicker()
        setupVehiclePicker()
    }
    
    func configureView() {
        if let detail = detailItem {
            let task = detail as! TaskRoute
            self.garbages = task.garbageList
            DispatchQueue.main.async {
                self.garbagePicker.reloadAllComponents()
            }
        }
        
        if let taskAmountItem = taskAmount {
            let taskAmount = taskAmountItem as! TaskAmount
            self.selectedGarbage = taskAmount.garbage
            self.garbageLabel?.text = taskAmount.garbage.name
            self.selectedVehicle = taskAmount.vehicle
            self.vehicleLabel?.text = taskAmount.vehicle?.registrationNumber
            self.amountLabel?.text = String(taskAmount.amount)
            self.memoLabel?.text = taskAmount.memo
            
            self.deleteButton?.isEnabled = true
            self.title = "Edit Task Garbage Amount"
        }
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.amountLabel.resignFirstResponder();
        self.memoLabel.resignFirstResponder();
        self.garbageLabel.resignFirstResponder();
        self.vehicleLabel.resignFirstResponder();
    }

    @objc
    func saveClicked(_ sender: Any) {
        if selectedGarbage == nil {
            let addAlert = UIAlertController(title: "Please select a garbage type !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        
        if selectedVehicle == nil {
            let addAlert = UIAlertController(title: "Please select a vehicle !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }

        if amountLabel.text?.count == 0 {
            let addAlert = UIAlertController(title: "Please enter a garbage amount !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        addOrEditGarbageAmount()
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Task Amount ?", message: "Are you sure you want to delete the amount ?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes. Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTaskAmount()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteTaskAmount() {
        if let taskAmountItem = taskAmount {
            let taskAmount = taskAmountItem as! TaskAmount
            let headers = APIHeaders.getHeaders()
            AF.request(Environment.SERVER_URL + "api/task_amount/"+String(taskAmount.id)+"/", method: .delete, headers: headers)
                .validate()
                .responseString {
                    response in
                    switch response.result {
                    case .success(_):
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    func addOrEditGarbageAmount() {
        let garbageId = selectedGarbage?.id
        let vehicleId = selectedVehicle?.id
        let taskId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!

        let parameters: [String: String] = [
            "garbage": String(garbageId!),
            "vehicle": String(vehicleId!),
            "amount": self.amountLabel.text!,
            "memo": self.memoLabel.text!,
            "route": String(taskId)
        ]
        
        var url = Environment.SERVER_URL + "api/task_amount/"
        var method = "POST"
        let headers = APIHeaders.getHeaders()
        
        if taskAmount != nil {
            if let taskAmountItem = taskAmount {
                let taskAmount = taskAmountItem as! TaskAmount
                url = url + String(taskAmount.id) + "/"
                method = "PATCH"
            }
        }
        
        AF.request(url, method: HTTPMethod(rawValue: method), parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseJSON {
                response in
                switch response.result {
                case .success(_):
                    _ = self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @objc
    func garbagePickerDone() {
        garbageLabel.resignFirstResponder()
    }
    
    @objc
    func vehiclePickerDone() {
        vehicleLabel.resignFirstResponder()
    }
    
    func setupGarbagePicker() {
        garbagePicker.backgroundColor = UIColor.white
        
        garbagePicker.delegate = self
        garbagePicker.dataSource = self
        garbagePicker.tag = 1
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.garbagePickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        garbageLabel.inputView = garbagePicker
        garbageLabel.inputAccessoryView = toolBar
    }
    
    func setupVehiclePicker() {
        vehiclePicker.backgroundColor = UIColor.white
        
        vehiclePicker.delegate = self
        vehiclePicker.dataSource = self
        vehiclePicker.tag = 2
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.vehiclePickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        vehicleLabel.inputView = vehiclePicker
        vehicleLabel.inputAccessoryView = toolBar
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return self.garbages.count
        }
        
        if pickerView.tag == 2 {
            return self.vehicles.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return self.garbages[row].name
        }
        
        if pickerView.tag == 2 {
            return self.vehicles[row].registrationNumber
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            let garbage = self.garbages[row]
            self.selectedGarbage = garbage
            self.garbageLabel.text = garbage.name
            return
        }
        
        if pickerView.tag == 2 {
            let vehicle = self.vehicles[row]
            self.selectedVehicle = vehicle
            self.vehicleLabel.text = vehicle.registrationNumber
            return
        }
    }
    
    // text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            return true
        }
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        if string == numberFiltered {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            _ = currentText.replacingCharacters(in: stringRange, with: string)
            return true
        } else {
            return false
        }
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
