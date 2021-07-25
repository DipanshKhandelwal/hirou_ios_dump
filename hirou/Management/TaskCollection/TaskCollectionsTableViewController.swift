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

class TaskCollectionsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var taskCollections = [TaskCollection]()
    @IBOutlet weak var collectionPointImage: UIImageView! {
        didSet {
            collectionPointImage.image = UIImage(systemName: "house")
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    
    @IBOutlet weak var collectionStack: UIStackView! {
        didSet {
            collectionStack.axis = .horizontal
            collectionStack.spacing = 10
            collectionStack.distribution = .fillEqually
        }
    }
    
    func updateCollectionStack () {
        collectionStack.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        for num in 0...taskCollections.count-1 {
            let taskCollection = taskCollections[num];
            let garbageView = UIButton(type: .system)
            garbageView.setTitle(taskCollection.garbage.name, for: .normal)
            garbageView.layer.borderWidth = 1
            garbageView.layer.cornerRadius = 20
            garbageView.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            garbageView.layer.backgroundColor = taskCollection.complete ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
            garbageView.layer.borderColor = taskCollection.complete ? UIColor.systemBlue.cgColor : UIColor.systemGray3.cgColor
            garbageView.setTitleColor(.black, for: .normal)
            collectionStack.addArrangedSubview(garbageView)
        }
    }
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.title = "Collections"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //         self.navigationItem.rightBarButtonItem = self.editButtonItem
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsVListUpdate, object: nil)
        
        updateCollectionStack()
    }
    
    @objc
    func collectionPointUpdateFromVList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        var changedIndexes = [IndexPath]()
        for tc in tcs {
            for num in 0...self.taskCollections.count-1 {
                if self.taskCollections[num].id == tc.id {
                    self.taskCollections[num] = tc
                    changedIndexes.append(IndexPath(row: num, section: 0))
                    break
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: changedIndexes, with: .automatic)
        }
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var route: Any?
    
    func configureView() {
        if let detail = detailItem {
            let collectionPoint = (detail as! TaskCollectionPoint)
            self.taskCollections = collectionPoint.taskCollections
            self.title = collectionPoint.name
            
            DispatchQueue.global().async { [] in
                let url = NSURL(string: collectionPoint.image)! as URL
                if let imageData: NSData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.collectionPointImage?.image = UIImage(data: imageData as Data)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if (self.tableView != nil) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.taskCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        if let headers = APIHeaders.getHeaders() {
            request.headers = headers
        }
        
        AF.request(request)
            .validate()
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let taskCollection = try! JSONDecoder().decode(TaskCollection.self, from: value!)
                    self.taskCollections[position] = taskCollection
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [ IndexPath(row: position, section: 0) ], with: .automatic)
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: [taskCollection])
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "taskCollectionsToReportAdminFormSegue" {
            let controller = (segue.destination as! ReportAdminFormViewController)
            if let detail = detailItem {
                controller.detailItem = self.route
                controller.segueTaskCollectionPoint = (detail as! TaskCollectionPoint)
            }
        }
        
        if segue.identifier == "taskCollectionsToTaskAmountFormSegue" {
            let controller = (segue.destination as! TaskGarbageAmountFormViewController)
            
//            if let detail = detailItem {
//                controller.detailItem = self.route
//                controller.segueTaskCollectionPoint = (detail as! TaskCollectionPoint)
//            }
            controller.detailItem = self.route
        }
    }
}
