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
    
    var vehiclesList = [Vehicle]()
    var selectedVehicle: Vehicle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        
        vehiclePicker.delegate = self
        vehiclePicker.dataSource = self
        vehiclePicker.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(vehicleLabelPressed))
        vehicleLabel.addGestureRecognizer(tap)
    }
    
    @objc
    func vehicleLabelPressed(sender: UITapGestureRecognizer) {
        vehiclePicker.isHidden = !vehiclePicker.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request("http://127.0.0.1:8000/api/vehicle/", method: .get).responseJSON { response in
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
                label.text = task.customer.name
            }
            
            if let label = self.vehicleLabel {
                label.text = "Vehicle"
            }
            
            if let label = self.garbageLabel {
                label.text = task.getGarbagesNameList()
            }
        }
    }
    
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
