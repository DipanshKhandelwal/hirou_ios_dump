//
//  TaskAddViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 29/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class TaskAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var routeLabel: DisabledUITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let picker: UIPickerView
        picker = UIPickerView()
        picker.backgroundColor = UIColor.white

        picker.delegate = self
        picker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.pickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        routeLabel.inputView = picker
        routeLabel.inputAccessoryView = toolBar
        
        // Do any additional setup after loading the view.
    }
    
    @objc
    func pickerDone() {
        routeLabel.resignFirstResponder()
    }
    
    @objc
    func donePicker() {
        print("done picker")
    }
    

    @IBAction func cancelAddTask(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row", row)
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
