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
    
    var collectionPointPicker = UIPickerView()
    var reportTypePicker = UIPickerView()

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
