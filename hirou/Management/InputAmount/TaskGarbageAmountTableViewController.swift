//
//  InputAmountTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 09/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskGarbageAmountTableViewCell: UITableViewCell {
    @IBOutlet weak var garbageType: UILabel!
    @IBOutlet weak var amount: UILabel!
}

class TaskGarbageAmountTableViewController: UITableViewController {
    var taskAmounts = [TaskAmount]()
    
    var detailItem: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Task Garbage Amount"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTaskGarbageAmounts()
    }
    
    func fetchTaskGarbageAmounts(){
        let id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        let url = Environment.SERVER_URL + "api/task_amount/"
        let parameters: Parameters = [ "task_route": id ]
        AF.request(url, method: .get, parameters: parameters).validate().response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.taskAmounts = try! decoder.decode([TaskAmount].self, from: value!)
                print(self.taskAmounts.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
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
        return self.taskAmounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskGarbageAmountTableViewCell", for: indexPath) as! TaskGarbageAmountTableViewCell
        let taskAmount = self.taskAmounts[indexPath.row]
        cell.garbageType?.text = taskAmount.garbage.name
        cell.amount?.text = String(taskAmount.amount)
        return cell
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inputTaskAmountFormSegue" {
            let controller = (segue.destination as! TaskGarbageAmountFormViewController)
            if detailItem != nil {
                controller.detailItem = self.detailItem
            }
        }
        else if segue.identifier == "editGarbageAmount" {
            let controller = (segue.destination as! TaskGarbageAmountFormViewController)
            if let indexPath = tableView.indexPathForSelectedRow {
                if detailItem != nil {
                    controller.detailItem = self.detailItem
                    controller.taskAmount = self.taskAmounts[indexPath.row]
                }
            }
        }
    }
}
