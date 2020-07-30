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
    var selectedCollectionPoint: Int?
    
    var reportTypes = [ReportType]()
    var selectedReportType: ReportType?
    var selectedImage: UIImage?
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        setupPickers()
        self.deleteButton?.isEnabled = false
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchReportTypes();
        fetchCollectionPoints();
        super.viewWillAppear(animated)
    }
    
    var taskReport: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let taskReportItem = taskReport {
            let taskReport = taskReportItem as! TaskReport
            
            self.selectedReportType = taskReport.reportType
            self.reportTypeLabel?.text = taskReport.reportType.name

            self.selectedCollectionPoint = taskReport.collectionPoint
            
            if let image = self.reportImage {
                if taskReport.image != nil {
                    image.image = UIImage(systemName: "doc")
                    DispatchQueue.global().async { [] in
                        let url = NSURL(string: taskReport.image!)! as URL
                        if let imageData: NSData = NSData(contentsOf: url) {
                            DispatchQueue.main.async {
                                image.image = UIImage(data: imageData as Data)
                            }
                        }
                    }
                }
            }
            
            self.addButton?.setTitle("Save", for: .normal)
            self.deleteButton?.isEnabled = true
            self.title = "Edit Report Admin Form"
        }
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
                if self.collectionPointLabel?.text?.count == 0 {
                    for cp in self.collectionPoints {
                        if cp.id == self.selectedCollectionPoint {
                            self.collectionPointLabel?.text = cp.name
                        }
                    }
                }
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
    
    func saveImage(id: Int) {
        let image = self.selectedImage
        if image == nil {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let imgData = image!.jpegData(compressionQuality: 0.2)!
        let reportId = id
                        
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imgData, withName: "image", fileName: String(reportId)+".png", mimeType: "image/png")
        },
                  to: Environment.SERVER_URL + "api/task_report/"+String(id)+"/",
                  method: .patch
        )
            .uploadProgress( queue: .main, closure: {
                progress in
                print("Upload Progress: \(progress.fractionCompleted)")
                if progress.fractionCompleted == 1 {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }).responseJSON(completionHandler: { data in
                print("upload finished: \(data)")
                _ = self.navigationController?.popViewController(animated: true)
            }).response { (response) in
                switch response.result {
                case .success(let result):
                    print("upload success result: \(String(describing: result))")
                case .failure(let err):
                    print("upload err: \(err)")
                }
        }
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
    
    @IBAction func handleDeleteClicked(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Task Report ?", message: "Are you sure you want to delete the report ?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes. Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTaskReport()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
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
        let collectionPointId = selectedCollectionPoint
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
                    let id = ((value as AnyObject)["id"] as! Int)
                    self.saveImage(id: id)

                case .failure(let error):
                    print(error)
                }
        }
    }

    func deleteTaskReport() {
        if let taskReportItem = taskReport {
        let taskReport = taskReportItem as! TaskReport
            AF.request(Environment.SERVER_URL + "api/task_report/"+String(taskReport.id)+"/", method: .delete)
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
            if row < self.collectionPoints.count {
                let collectionPoint = self.collectionPoints[row]
                self.selectedCollectionPoint = collectionPoint.id
                self.collectionPointLabel.text = collectionPoint.name
            }
        }
        else {
            if row < self.reportTypes.count {
                // picker is report type
                let reportType = self.reportTypes[row]
                self.selectedReportType = reportType
                self.reportTypeLabel.text = reportType.name
            }
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
