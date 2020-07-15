//
//  ReportAdminFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class ReportAdminFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var collectionPointLabel: DisabledUITextField!
    @IBOutlet weak var reportTypeLabel: DisabledUITextField!
    
    var collectionPointPicker = UIPickerView() // tag = 1
    var reportTypePicker = UIPickerView() // tag = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        setupPickers()
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.collectionPointLabel.resignFirstResponder();
        self.reportTypeLabel.resignFirstResponder();
    }
    
    @IBAction func cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func setupPickers() {
        setupCollectionPointPicker()
        setupReportTypePicker();
    }

    func setupCollectionPointPicker() {
        collectionPointPicker.backgroundColor = UIColor.white
        collectionPointPicker.tag = 1
        
        collectionPointPicker.delegate = self
        collectionPointPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.collectionPointPickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        collectionPointLabel.inputView = collectionPointPicker
        collectionPointLabel.inputAccessoryView = toolBar
    }
    
    func setupReportTypePicker() {
        reportTypePicker.backgroundColor = UIColor.white
        reportTypePicker.tag = 2
        
        reportTypePicker.delegate = self
        reportTypePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.reportTypePickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        reportTypeLabel.inputView = reportTypePicker
        reportTypeLabel.inputAccessoryView = toolBar
    }
    
    @objc
    func collectionPointPickerDone() {
        collectionPointLabel.resignFirstResponder();
    }
    
    @objc
    func reportTypePickerDone() {
        reportTypeLabel.resignFirstResponder();
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1) {
            // picker is collection point picker
            return self.collectionPoints.count
        }
        else {
            // picker is report type
            return self.reportTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1) {
            // picker is collection point picker
            return self.collectionPoints[row].name
        }
        else {
            // picker is report type
            return self.reportTypes[row].name
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
