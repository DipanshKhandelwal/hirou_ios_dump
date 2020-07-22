//
//  TaskCollectionPointTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 07/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskCollectionPointCell: UITableViewCell {
    @IBOutlet weak var sequence: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var garbageStack: UIStackView!
}

class TaskCollectionPointTableViewController: UITableViewController {
    var taskCollectionPoints: [TaskCollectionPoint] = []
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromHList(_:)), name: .TaskCollectionPointsHListUpdate, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromMap(_:)), name: .TaskCollectionPointsMapSelect, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsHListUpdate, object: nil)
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsMapSelect, object: nil)
    }
    
    @objc
    func collectionPointUpdateFromHList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        var changedIndexes = [IndexPath]()
        for tc in tcs {
            for tcp_num in 0...self.taskCollectionPoints.count-1 {
                let tcp = self.taskCollectionPoints[tcp_num]
                for num in 0...tcp.taskCollections.count-1 {
                    if tcp.taskCollections[num].id == tc.id {
                        tcp.taskCollections[num] = tc
                        changedIndexes.append(IndexPath(row: tcp_num, section: 0))
                        break;
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: changedIndexes, with: .right)
        }
    }
    
    @objc
    func collectionPointSelectFromMap(_ notification: Notification) {
        let tcp = notification.object as! TaskCollectionPoint
        for num in 0...self.taskCollectionPoints.count-1 {
            if self.taskCollectionPoints[num].id == tcp.id {
                self.tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        fetchTaskCollectionPoints()
    }
    
    func fetchTaskCollectionPoints(){
        let id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        let url = Environment.SERVER_URL + "api/task_route/"+String(id)+"/"
        AF.request(url, method: .get).response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                let newCollectionPoints = route.taskCollectionPoints
                self.taskCollectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
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
        return self.taskCollectionPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCollectionPointCell", for: indexPath) as! TaskCollectionPointCell
        
        let tcp = self.taskCollectionPoints[indexPath.row]
        cell.sequence!.text = String(tcp.sequence)
        cell.name!.text = tcp.name
        cell.memo!.text = tcp.memo
        
        cell.garbageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cell.garbageStack.spacing = 10
        cell.garbageStack.axis = .horizontal
        cell.garbageStack.distribution = .equalCentering
        
        let toggleAllTasksButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toggleAllTasksButton.tag = indexPath.row;
        toggleAllTasksButton.addTarget(self, action: #selector(TaskNavigationViewController.toggleAllTasks(sender:)), for: .touchDown)
        toggleAllTasksButton.layer.backgroundColor = tcp.getCompleteStatus() ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
        toggleAllTasksButton.layer.borderWidth = 2
        toggleAllTasksButton.layer.borderColor = UIColor.red.cgColor
        toggleAllTasksButton.layer.cornerRadius = 10
        toggleAllTasksButton.setTitle("*", for: .normal)
        toggleAllTasksButton.titleLabel?.font = toggleAllTasksButton.titleLabel?.font.withSize(20)
        toggleAllTasksButton.setTitleColor(.black, for: .normal)
        cell.garbageStack.addArrangedSubview(toggleAllTasksButton)

        for num in 0...tcp.taskCollections.count-1 {
            let taskCollection = tcp.taskCollections[num];
            
            let garbageView = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), taskCollectionPointPosition: indexPath.row, taskPosition: num)
            garbageView.addTarget(self, action: #selector(TaskCollectionPointTableViewController.pressed(sender:)), for: .touchDown)
            garbageView.layer.backgroundColor = taskCollection.complete ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
            garbageView.layer.borderWidth = 2
            garbageView.layer.borderColor = UIColor.systemBlue.cgColor
            garbageView.layer.cornerRadius = 10
            garbageView.setTitle(String(taskCollection.garbage.name.prefix(1)), for: .normal)
            garbageView.titleLabel?.font = garbageView.titleLabel?.font.withSize(15)
            garbageView.setTitleColor(.black, for: .normal)
            cell.garbageStack.addArrangedSubview(garbageView)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.notificationCenter.post(name: .TaskCollectionPointsHListSelect, object: self.taskCollectionPoints[indexPath.row])
    }
    
    @objc
    func toggleAllTasks(sender: UIButton) {
        let taskCollectionPoint = self.taskCollectionPoints[sender.tag]
        let url = Environment.SERVER_URL + "api/task_collection_point/"+String(taskCollectionPoint.id)+"/bulk_complete/"
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(request)
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let taskCollectionsNew = try! JSONDecoder().decode([TaskCollection].self, from: value!)
                    self.taskCollectionPoints[sender.tag].taskCollections = taskCollectionsNew
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [ IndexPath(row: sender.tag, section: 0) ], with: .automatic)
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsVListUpdate, object: taskCollectionsNew)
                case .failure(let error):
                    print(error)
                }
        }
    }

    @objc
    func pressed(sender: GarbageButton) {
        let taskCollectionPoint = self.taskCollectionPoints[sender.taskCollectionPointPosition]
        let taskCollection = taskCollectionPoint.taskCollections[sender.taskPosition]
        
        let url = Environment.SERVER_URL + "api/task_collection/"+String(taskCollection.id)+"/"
        
        let values = [ "complete": !taskCollection.complete ] as [String : Any?]
                
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        AF.request(request)
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let taskCollectionNew = try! JSONDecoder().decode(TaskCollection.self, from: value!)
                    self.taskCollectionPoints[sender.taskCollectionPointPosition].taskCollections[sender.taskPosition] = taskCollectionNew
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: sender.taskCollectionPointPosition, section: 0)], with: .automatic)
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsVListUpdate, object: [taskCollectionNew])

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
