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
    @IBOutlet weak var taskCollectionPointLabel: DisabledUITextField!
    @IBOutlet weak var reportTypeLabel: DisabledUITextField!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UITextField!
    
    var taskCollectionPointPicker = UIPickerView() // tag = 1
    var reportTypePicker = UIPickerView() // tag = 2
    
    var imagePicker: ImagePicker!
    
    var collectionPoints = [TaskCollectionPoint]()
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
        
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(handleAddClick))
        navigationItem.setRightBarButton(saveButton, animated: true)
        
        setupPickers()
        self.deleteButton?.isEnabled = false
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchReportTypes();
        fetchTaskCollectionPoints();
        super.viewWillAppear(animated)
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var taskReport: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var segueTaskCollectionPoint: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var currentTaskCollectionPoint : TaskCollectionPoint?
    
    func setTaskCollectionPointFromSegue() {
        if let taskCollectionPoint = segueTaskCollectionPoint {
            let receivedTaskCollectionPoint = (taskCollectionPoint as! TaskCollectionPoint)
            self.selectedCollectionPoint = receivedTaskCollectionPoint.id
            self.taskCollectionPointLabel?.text = receivedTaskCollectionPoint.name
            self.taskCollectionPointLabel?.isEnabled = false
            self.taskCollectionPointPicker.isUserInteractionEnabled = false
        }
    }
    
    func configureView() {
        
        if let currentTaskCollectionPoint = currentTaskCollectionPoint {
            taskCollectionPointLabel.text = currentTaskCollectionPoint.name
        }
        
        if let detail = detailItem {
            let task = detail as! TaskRoute
            self.collectionPoints = task.taskCollectionPoints
            
            if self.taskCollectionPointLabel?.text?.count == 0 {
                for cp in self.collectionPoints {
                    if cp.id == self.selectedCollectionPoint {
                        self.taskCollectionPointLabel?.text = cp.name
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.taskCollectionPointPicker.reloadAllComponents()
            }
        }
        
        if let taskReportItem = taskReport {
            let taskReport = taskReportItem as! TaskReport
            
            self.selectedReportType = taskReport.reportType
            self.reportTypeLabel?.text = taskReport.reportType.name
            self.descriptionLabel?.text = taskReport.description

            self.selectedCollectionPoint = taskReport.taskCollectionPoint
            
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
            self.title = "管理者報告フォーム"
        }
        
        setTaskCollectionPointFromSegue()
    }
    
    func fetchReportTypes() {
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/report_type/", method: .get, headers: headers).validate().response { response in
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
    
    func fetchTaskCollectionPoints() {
        let headers = APIHeaders.getHeaders()
        let taskId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        AF.request(Environment.SERVER_URL + "api/task_route/"+String(taskId)+"/", method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                let newCollectionPoints = route.taskCollectionPoints
                self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                DispatchQueue.main.async {
                    self.taskCollectionPointPicker.reloadAllComponents()
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
    
    func uploadImage(id: Int) {
        let image = self.selectedImage
        if image == nil {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let imgData = image!.jpegData(compressionQuality: 0.2)!
        let reportId = id
        let headers = APIHeaders.getHeaders()
                        
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imgData, withName: "image", fileName: String(reportId)+".png", mimeType: "image/png")
        },
        to: Environment.SERVER_URL + "api/task_report/"+String(id)+"/",
        method: .patch,
        headers: headers
        )
        .validate()
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
        self.descriptionLabel.resignFirstResponder()
        self.taskCollectionPointLabel.resignFirstResponder();
        self.reportTypeLabel.resignFirstResponder();
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    @IBAction func handleDeleteClicked(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "報告の削除", message: "報告を削除しますか？ ", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTaskReport()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @objc
    func handleAddClick() {
        if selectedCollectionPoint == nil {
            let addAlert = UIAlertController(title: "収集場所をお選びください!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        
        if selectedReportType == nil {
            let addAlert = UIAlertController(title: "分類を選択してください", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        }
        
        addNewOrEditReport()
    }
    
    func addNewOrEditReport() {
        let collectionPointId = selectedCollectionPoint
        let reportTypeId = selectedReportType?.id
        let description = self.descriptionLabel?.text
        let taskId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!

        let parameters: [String: String] = [
            "route": String(taskId),
            "task_collection_point": String(collectionPointId!),
            "report_type": String(reportTypeId!),
            "description": String(description!),
        ]
        
        var url = Environment.SERVER_URL + "api/task_report/"
        var method = "POST"
        let headers = APIHeaders.getHeaders()
        
        if taskReport != nil {
            if let taskReportItem = taskReport {
            let taskReport = taskReportItem as! TaskReport
                url = url + String(taskReport.id) + "/"
                method = "PATCH"
            }
        }

        AF.request(url, method: HTTPMethod(rawValue: method), parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    let id = ((value as AnyObject)["id"] as! Int)
                    self.uploadImage(id: id)

                case .failure(let error):
                    print(error)
                }
        }
    }

    func deleteTaskReport() {
        if let taskReportItem = taskReport {
            let headers = APIHeaders.getHeaders()
            let taskReport = taskReportItem as! TaskReport
            AF.request(Environment.SERVER_URL + "api/task_report/"+String(taskReport.id)+"/", method: .delete, headers: headers)
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

    func setupPickers() {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self);
        if segueTaskCollectionPoint == nil {
            setupTaskCollectionPointPicker()
        }
        setupReportTypePicker();
    }

    func setupTaskCollectionPointPicker() {
        taskCollectionPointPicker.backgroundColor = UIColor.white
        taskCollectionPointPicker.tag = 1
        
        taskCollectionPointPicker.delegate = self
        taskCollectionPointPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.taskCollectionPointPickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        taskCollectionPointLabel.inputView = taskCollectionPointPicker
        taskCollectionPointLabel.inputAccessoryView = toolBar
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
    func taskCollectionPointPickerDone() {
        taskCollectionPointLabel.resignFirstResponder();
        let row = taskCollectionPointPicker.selectedRow(inComponent: 0)
        guard row < collectionPoints.count else { return }
        let collectionPoint = self.collectionPoints[row]
        self.selectedCollectionPoint = collectionPoint.id
        self.taskCollectionPointLabel.text = collectionPoint.name
    }
    
    @objc
    func reportTypePickerDone() {
        reportTypeLabel.resignFirstResponder();
        let row = reportTypePicker.selectedRow(inComponent: 0)
        guard row < reportTypes.count else { return }
        let reportType = self.reportTypes[row]
        self.selectedReportType = reportType
        self.reportTypeLabel.text = reportType.name
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
                self.taskCollectionPointLabel.text = collectionPoint.name
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
