//
//  ReportAdminTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 09/07/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class ReportAdminTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionPoint: UILabel!
    @IBOutlet weak var reportType: UILabel!
}

class ReportAdminTableViewController: UITableViewController {
    var taskReports = [TaskReport]()
    
    var detailItem: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Report Admin"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTaskReports()
    }

    func fetchTaskReports(){
        let id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        let url = Environment.SERVER_URL + "api/task_report/"
        let parameters: Parameters = [ "task_route": id ]
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, parameters: parameters, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.taskReports = try! decoder.decode([TaskReport].self, from: value!)
                print(self.taskReports.count)
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
        return self.taskReports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportAdminTableViewCell", for: indexPath) as! ReportAdminTableViewCell
        let taskReport = self.taskReports[indexPath.row]
        if taskReport.taskCollectionPoint != nil {
            cell.collectionPoint?.text =  String(taskReport.taskCollectionPoint!)
        }else {
            cell.collectionPoint?.text =  "--"
        }
        cell.reportType?.text = taskReport.reportType.name
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inputTaskReportFormSegue" {
            let controller = (segue.destination as! ReportAdminFormViewController)
            if detailItem != nil {
                controller.detailItem = self.detailItem
            }
        } else if segue.identifier == "editAdminReport" {
            let controller = (segue.destination as! ReportAdminFormViewController)
            if let indexPath = tableView.indexPathForSelectedRow {
                controller.taskReport = self.taskReports[indexPath.row]
                controller.detailItem = self.detailItem
            }
        }
    }
}
