//
//  TaskAddViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 29/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var routeLabel: DisabledUITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    var baseRoutes = [BaseRoute]()
    var baseRoutePicker = UIPickerView()
    var selectedBaseRoute: BaseRoute?
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseRoutePicker()
        configureView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(addNewTaskHandler))
        navigationItem.setRightBarButton(saveButton, animated: true)
        
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.taskName.resignFirstResponder()
        routeLabel.resignFirstResponder()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            if let detail = detailItem {
                let date = detail as! Date
                self.date = date
                configureView()
            }
        }
    }
    
    func configureView()  {
        if let label = self.dateLabel {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            label.text = dateFormatter.string(from: self.date)
        }
    }
    
    @objc
    func addNewTaskHandler() {
        if selectedBaseRoute == nil {
            let addAlert = UIAlertController(title: "Please select a base route !!", message: "", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
            self.present(addAlert, animated: true, completion: nil)
            return
        } else {
            addNewTask()
        }
    }
    
    func addNewTask () {
        let routeId = selectedBaseRoute?.id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let parameters: [String: String] = [
            "name": String(self.taskName.text!),
            "id": String(routeId!),
            "date": dateFormatter.string(from: self.date)
        ]
        let headers = APIHeaders.getHeaders()

        AF.request(Environment.SERVER_URL + "api/task_route/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
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
    
    override func viewWillAppear(_ animated: Bool) {
        let headers = APIHeaders.getHeaders()
        let parameters: Parameters = [ "type": "list" ]
        AF.request(Environment.SERVER_URL + "api/base_route/", method: .get, parameters: parameters, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success(let value):
                    let decoder = JSONDecoder()
                    let baseRoutesList = try! decoder.decode([BaseRoute].self, from: value!)
                    self.baseRoutes = baseRoutesList.sorted() { $0.name < $1.name }
                    DispatchQueue.main.async {
                        self.baseRoutePicker.reloadAllComponents()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        super.viewWillAppear(animated)
    }
    
    
    // picker
    func setupBaseRoutePicker() {
        baseRoutePicker.backgroundColor = UIColor.white
        
        baseRoutePicker.delegate = self
        baseRoutePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.pickerDone))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        routeLabel.inputView = baseRoutePicker
        routeLabel.inputAccessoryView = toolBar
    }
    
    @objc
    func pickerDone() {
        routeLabel.resignFirstResponder()
        let row = baseRoutePicker.selectedRow(inComponent: 0)
        guard row < baseRoutes.count else { return }
        let route = self.baseRoutes[row]
        self.selectedBaseRoute = route
        self.routeLabel?.text = route.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateMonthText = dateFormatter.string(from: self.date)
        self.taskName?.text = dateMonthText + " : " + route.name
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return baseRoutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return baseRoutes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < self.baseRoutes.count {
            let route = self.baseRoutes[row]
            self.selectedBaseRoute = route
            self.routeLabel?.text = route.name

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            let dateMonthText = dateFormatter.string(from: self.date)
            self.taskName?.text = dateMonthText + " : " + route.name
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
