//
//  TaskDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var garbageLabel: UILabel!
    @IBOutlet weak var vehiclePicker: UIPickerView!
    
    
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    var vehiclesList = [Vehicle]()
    var selectedVehicle: Vehicle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        vehiclePicker.delegate = self
        vehiclePicker.dataSource = self
        vehiclePicker.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(vehicleLabelPressed))
        vehicleLabel.addGestureRecognizer(tap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        configureView()
    }
    
    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        vehiclePicker.isHidden = true
    }
    
    @objc
    func vehicleLabelPressed(sender: UITapGestureRecognizer) {
        vehiclePicker.isHidden = !vehiclePicker.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request(Environment.SERVER_URL + "api/vehicle/", method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("response", value)
                self.vehiclesList = []
                for vehicle in value as! [Any] {
                    let vehicleObj = Vehicle.getVehicleFromResponse(obj: vehicle as AnyObject)
                    self.vehiclesList.append(vehicleObj)
                }
                self.vehiclePicker.reloadAllComponents()
            case .failure(let error):
                print(error)
                //                completion(nil)
            }
            
        }
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            if let detail = detailItem {
                let taskRoute = detail as! TaskRoute
                print("taskRoute.name", taskRoute.name)
                configureView()
            }
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            let task = detail as! TaskRoute
            
            UserDefaults.standard.set(task.id, forKey: "selectedTaskRoute")
            
            if let label = self.customerLabel {
                label.text = task.customer?.name ?? "n/a"
            }
            
            if let label = self.vehicleLabel {
                label.text = "Vehicle"
            }
            
            if let label = self.garbageLabel {
                label.text = task.getGarbagesNameList()
            }
        } else {
            if let label = self.customerLabel {
                label.text = "n/a"
            }
            
            if let label = self.garbageLabel {
                label.text = "n/a"
            }
            
            if let button = self.deleteTaskButton {
                button.isHidden = true
            }
        }
    }
    
    // button pressed
    
    @IBAction func deleteTask(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Task ?", message: "Are you sure you want to delete the task ?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes. Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTaskCall()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteTaskCall(){
        if let detail = detailItem {
            let id = (detail as! TaskRoute).id
            AF.request(Environment.SERVER_URL + "api/task_route/"+String(id)+"/", method: .delete)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                        //                completion(nil)
                    }
            }
        }
    }
    
    // picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.vehiclesList.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if(self.vehiclesList.count >= row) {
            return self.vehiclesList[row].registrationNumber
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.vehiclesList.count >= row) {
            self.vehicleLabel.text = self.vehiclesList[row].registrationNumber
            print(self.vehiclesList[row].registrationNumber)
            //            self.selectedCustomerId = self.customers[row].id
        }
        self.vehiclePicker.isHidden = true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //        if segue.identifier == "selectGarbageTypes" {
        //            let controller = (segue.destination as! GarbageTypesTableViewController)
        //            if let detail = detailItem {
        //                controller.detailItem = self.selectedGarbages
        //                controller.delegate = self
        //            }
        //        }
    }
    
}
