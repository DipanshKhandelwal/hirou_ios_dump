//
//  InputAmountFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskGarbageAmountFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var garbages = [Garbage]()
    var selectedGarbage: Garbage?
    
    var garbagePicker = UIPickerView()

    @IBOutlet weak var garbageLabel: DisabledUITextField!
    @IBOutlet weak var amountLabel: DisabledUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGarbagePicker()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
