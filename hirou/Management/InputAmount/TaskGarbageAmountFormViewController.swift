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
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var garbages = [Garbage]()
    var selectedGarbage: Garbage?
    
    var garbagePicker = UIPickerView()
    
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
    @IBOutlet weak var amountLabel: DisabledUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGarbagePicker()
        amountLabel.delegate = self
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.deleteButton?.isEnabled = false
        configureView()
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
            self.amountLabel?.text = String(taskAmount.amount)
            
            self.addButton?.setTitle("Save", for: .normal)
            self.deleteButton?.isEnabled = true
            self.title = "Edit Task Garbage Amount"
        }
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.amountLabel.resignFirstResponder();
        self.garbageLabel.resignFirstResponder();
    }

    @IBAction func cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addClicked(_ sender: Any) {
        if selectedGarbage == nil {
            let addAlert = UIAlertController(title: "Please select a garbage type !!", message: "", preferredStyle: .alert)
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
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    func addOrEditGarbageAmount() {
        let garbageId = selectedGarbage?.id
        let taskId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!

        let parameters: [String: String] = [
            "garbage": String(garbageId!),
            "amount": self.amountLabel.text!,
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
                case .success(let value):
                    print("value", value)
                    _ = self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @objc
    func pickerDone() {
        garbageLabel.resignFirstResponder()
    }
    
    func setupGarbagePicker() {
        garbagePicker.backgroundColor = UIColor.white
        
        garbagePicker.delegate = self
        garbagePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.pickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        garbageLabel.inputView = garbagePicker
        garbageLabel.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.garbages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.garbages[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let garbage = self.garbages[row]
        self.selectedGarbage = garbage
        self.garbageLabel.text = garbage.name
    }
    
    // text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
