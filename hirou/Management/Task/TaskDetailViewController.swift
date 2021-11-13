//
//  TaskDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var garbageLabel: UILabel!
    
    @IBOutlet weak var deleteTaskButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            if detailItem != nil {
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
                button.isEnabled = false
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
            let headers = APIHeaders.getHeaders()
            let id = (detail as! TaskRoute).id
            AF.request(Environment.SERVER_URL + "api/task_route/"+String(id)+"/", method: .delete, headers: headers)
                .validate()
                .responseString {
                    response in
                    switch response.result {
                    case .success( _):
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
    }
}
