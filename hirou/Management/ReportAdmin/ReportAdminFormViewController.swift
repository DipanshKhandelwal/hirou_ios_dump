//
//  ReportAdminFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 10/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class ReportAdminFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ImagePickerDelegate {
    @IBOutlet weak var collectionPointLabel: DisabledUITextField!
    @IBOutlet weak var reportTypeLabel: DisabledUITextField!
    @IBOutlet weak var reportImage: UIImageView!
    
    var collectionPointPicker = UIPickerView() // tag = 1
    var reportTypePicker = UIPickerView() // tag = 2
    
    var imagePicker: ImagePicker!
    
    var collectionPoints = [CollectionPoint]()
    var selectedCollectionPoint: CollectionPoint?
    
    var reportTypes = [ReportType]()
    var selectedReportType: ReportType?
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        setupPickers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchReportTypes();
        fetchCollectionPoints();
        super.viewWillAppear(animated)
    }
    
    func fetchReportTypes() {
        AF.request(Environment.SERVER_URL + "api/report_type/", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.reportTypes = try! JSONDecoder().decode([ReportType].self, from: value!)
                DispatchQueue.main.async {
                    self.reportTypePicker.reloadAllComponents()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCollectionPoints() {
        AF.request(Environment.SERVER_URL + "api/collection_point/", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.collectionPoints = try! JSONDecoder().decode([CollectionPoint].self, from: value!)
                DispatchQueue.main.async {
                    self.collectionPointPicker.reloadAllComponents()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didSelect(image: UIImage?) {
        self.selectedImage = image
        self.reportImage.image = image
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.collectionPointLabel.resignFirstResponder();
        self.reportTypeLabel.resignFirstResponder();
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleAddClick(_ sender: Any) {
        if selectedCollectionPoint == nil {
            let addAlert = UIAlertController(title: "Please select a collection point !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        
        if selectedReportType == nil {
            let addAlert = UIAlertController(title: "Please select a report type !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        
        addNewReport()
    }
    
    func addNewReport() {
        let collectionPointId = selectedCollectionPoint?.id
        let reportTypeId = selectedReportType?.id
        let taskId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!

        let parameters: [String: String] = [
            "route": String(taskId),
            "collection_point": String(collectionPointId!),
            "report_type": String(reportTypeId!),
        ]

        AF.request(Environment.SERVER_URL + "api/task_report/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
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

    func setupPickers() {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self);
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1) {
            // picker is collection point picker
            let collectionPoint = self.collectionPoints[row]
            self.selectedCollectionPoint = collectionPoint
            self.collectionPointLabel.text = collectionPoint.name
        }
        else {
            // picker is report type
            let reportType = self.reportTypes[row]
            self.selectedReportType = reportType
            self.reportTypeLabel.text = reportType.name
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
