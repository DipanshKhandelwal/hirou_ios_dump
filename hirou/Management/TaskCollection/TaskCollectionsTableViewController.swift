//
//  TaskCollectionsTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 06/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskCollectionsCell : UITableViewCell {
    @IBOutlet weak var garbageLabel: UILabel!
    @IBOutlet weak var collectionSwitch: UISwitch!
    @IBOutlet weak var pickupTimeLabel: UILabel!
}

class TaskCollectionsTableViewController: UITableViewController {
    var taskCollections = [TaskCollection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.title = "Collections"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            let collectionPoint = (detail as! TaskCollectionPoint)
            self.taskCollections = collectionPoint.taskCollections
            self.title = collectionPoint.name
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.taskCollections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath) as! TaskCollectionsCell
        
        let row = indexPath.row
        let taskCollection = self.taskCollections[indexPath.row]
        
        cell.garbageLabel!.text = taskCollection.garbage.name
        cell.pickupTimeLabel!.text = taskCollection.timestamp ?? "none"
        
        cell.collectionSwitch.isOn = taskCollection.complete
        cell.collectionSwitch.tag = row
        cell.collectionSwitch!.addTarget(self, action: #selector(switchToggle(_:)), for: .valueChanged)
        return cell
    }
    
    @objc
    func switchToggle(_ sender: UISwitch) {
        let taskCollection = self.taskCollections[sender.tag]
        setTaskCollectionComplete(taskId: taskCollection.id, switchState: sender.isOn, position: sender.tag)
    }
    
    func setTaskCollectionComplete(taskId: Int, switchState: Bool, position: Int) {
        let url = Environment.SERVER_URL + "api/task_collection/"+String(taskId)+"/"
        
        let values = [ "complete": switchState ] as [String : Any?]
                
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        AF.request(request)
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let taskCollection = try! JSONDecoder().decode(TaskCollection.self, from: value!)
                    self.taskCollections[position] = taskCollection
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                case .failure(let error):
                    print(error)
                }
        }
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
