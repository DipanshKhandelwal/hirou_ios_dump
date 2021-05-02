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

class GarbageSummaryCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var amount: UILabel!
}

struct GarbageListItem {
    var garbage: Garbage
    var complete: Int
    var total: Int
}

class TaskCollectionPointTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var taskCollectionPoints: [TaskCollectionPoint] = []
    var hideCompleted: Bool = false
    var garbageSummaryList: [GarbageListItem] = []
    
    private let notificationCenter = NotificationCenter.default
    
    let taskRouteId = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
    
    let socketConnection = WebSocketConnector(withSocketURL: URL(string: Environment.SERVER_SOCKET_URL + "updates/")!)
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var garbageSummaryTable: UITableView! {
        didSet {
            garbageSummaryTable.dataSource = self
            garbageSummaryTable.delegate = self
        }
    }
    
    func updateTaskCollectionPointFromEventData(taskCPData: Data) {
        let taskCP = try! JSONDecoder().decode(TaskCollectionPoint.self, from: taskCPData)
        if taskCP.taskRoute == Int(self.taskRouteId) {
            for (idx, tcp) in self.taskCollectionPoints.enumerated() {
                if tcp.id == taskCP.id {
                    self.taskCollectionPoints[idx] = taskCP
                    self.garbageSummaryList = self.getGarbageSummaryList(taskCollectionPoints: self.getTaskCollectionPoints())
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.garbageSummaryTable.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsVListUpdate, object: taskCP.taskCollections)
                }
            }
        }
    }
    
    private func setupConnection(){
        socketConnection.establishConnection()
        socketConnection.didReceiveMessage = {message in
            let dict = convertToDictionary(text: message)
            if let event = dict?[SocketKeys.EVENT] as?String, let sub_event = dict?[SocketKeys.SUB_EVENT] as?String {
                if event == SocketEventTypes.TASK_COLLECTION_POINT {
                    if sub_event == SocketSubEventTypes.BULK_COMPLETE {
                        let taskCPData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                        self.updateTaskCollectionPointFromEventData(taskCPData: taskCPData!)
                    }
                }
                else if event == SocketEventTypes.TASK_COLLECTION {
                    if sub_event == SocketSubEventTypes.UPDATE {
                        let taskCPData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                        self.updateTaskCollectionPointFromEventData(taskCPData: taskCPData!)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromHList(_:)), name: .TaskCollectionPointsHListUpdate, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromMap(_:)), name: .TaskCollectionPointsMapSelect, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(hideCompletedTriggered(_:)), name: .TaskCollectionPointsHideCompleted, object: nil)
        
        setupConnection()
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsHListUpdate, object: nil)
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsMapSelect, object: nil)
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsHideCompleted, object: nil)
    }
    
    func getTaskCollectionPoints () -> [TaskCollectionPoint] {
        if(hideCompleted) {
            return self.taskCollectionPoints.filter { !$0.getCompleteStatus() }
        }
        return self.taskCollectionPoints
    }
    
    @objc
    func collectionPointUpdateFromHList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        var changedIndexes = [IndexPath]()
        for tc in tcs {
            for tcp_num in 0...getTaskCollectionPoints().count-1 {
                let tcp = getTaskCollectionPoints()[tcp_num]
                for num in 0...tcp.taskCollections.count-1 {
                    if tcp.taskCollections[num].id == tc.id {
                        tcp.taskCollections[num] = tc
                        changedIndexes.append(IndexPath(row: tcp_num, section: 0))
                        break;
                    }
                }
            }
        }
        self.garbageSummaryList = getGarbageSummaryList(taskCollectionPoints: getTaskCollectionPoints())
        DispatchQueue.main.async {
            self.tableView.reloadData()
//            self.tableView.reloadRows(at: changedIndexes, with: .right)
            self.garbageSummaryTable.reloadData()
        }
    }
    
    @objc
    func collectionPointSelectFromMap(_ notification: Notification) {
        let tcp = notification.object as! TaskCollectionPoint
        for num in 0...getTaskCollectionPoints().count-1 {
            if getTaskCollectionPoints()[num].id == tcp.id {
                self.tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }
    
    @objc
    func hideCompletedTriggered(_ notification: Notification) {
        let status = notification.object as! Bool
        self.hideCompleted = status
        self.garbageSummaryList = self.getGarbageSummaryList(taskCollectionPoints: self.getTaskCollectionPoints())
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.garbageSummaryTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let indexPath = tableView.indexPathForSelectedRow() {
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            }
//
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        fetchTaskCollectionPoints()
    }
    
    func updateDataFromTaskRoute(taskRoute: TaskRoute) {
        let newCollectionPoints = taskRoute.taskCollectionPoints
        self.taskCollectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
        
        self.garbageSummaryList = self.getGarbageSummaryList(taskCollectionPoints: self.getTaskCollectionPoints())
        
        self.notificationCenter.post(name: .TaskCollectionPointsUpdate, object: self.taskCollectionPoints)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.garbageSummaryTable.reloadData()
        }
    }
    
    func fetchTaskCollectionPoints(){
        let id = self.taskRouteId
        let url = Environment.SERVER_URL + "api/task_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                self.updateDataFromTaskRoute(taskRoute: route)
            case .failure(let error):
                print(error)
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
        if tableView == self.tableView {
            return getTaskCollectionPoints().count
        }
        else {
            return self.garbageSummaryList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.garbageSummaryTable {
            return tableView.dequeueReusableCell(withIdentifier: "garbageSummaryTableCell", for: indexPath) as! GarbageSummaryCell
        }

        return tableView.dequeueReusableCell(withIdentifier: "taskCollectionPointCell", for: indexPath) as! TaskCollectionPointCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.garbageSummaryTable {
            let garbageListItem = self.garbageSummaryList[indexPath.row]
            let garbageCell = cell as! GarbageSummaryCell
            garbageCell.label!.text = garbageListItem.garbage.name
            garbageCell.amount!.text = String(garbageListItem.complete) + " / " + String(garbageListItem.total)
        }
        else {
            let tcpCell = cell as! TaskCollectionPointCell
            
            let tcp = getTaskCollectionPoints()[indexPath.row]
            tcpCell.sequence!.text = String(tcp.sequence)
            tcpCell.name!.text = tcp.name
            tcpCell.memo!.text = tcp.memo

            if tcp.taskCollections.count >= 1 {
                tcpCell.garbageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
                tcpCell.garbageStack.spacing = 10
                tcpCell.garbageStack.axis = .horizontal
                tcpCell.garbageStack.distribution = .equalCentering
                
                let toggleAllTasksButton = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                toggleAllTasksButton.tag = indexPath.row;
                toggleAllTasksButton.addTarget(self, action: #selector(TaskCollectionPointTableViewController.toggleAllTasks(sender:)), for: .touchDown)
                toggleAllTasksButton.layer.backgroundColor = tcp.getCompleteStatus() ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
                tcpCell.garbageStack.addArrangedSubview(toggleAllTasksButton)
                
                for num in 0...tcp.taskCollections.count-1 {
                    let taskCollection = tcp.taskCollections[num];
                    
                    let garbageView = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), taskCollectionPointPosition: indexPath.row, taskPosition: num, taskCollection: taskCollection)
                    garbageView.addTarget(self, action: #selector(TaskCollectionPointTableViewController.pressed(sender:)), for: .touchDown)
                    tcpCell.garbageStack.addArrangedSubview(garbageView)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            Sound.playInteractionSound()
            
            self.notificationCenter.post(name: .TaskCollectionPointsHListSelect, object: getTaskCollectionPoints()[indexPath.row])
        }
    }
    
    func isAllCompleted(taskCollectionPoint: TaskCollectionPoint) -> Bool {
        var completed = true;
        for taskCollection in taskCollectionPoint.taskCollections {
            if(!taskCollection.complete) {
                completed = false
                break
            }
        }
        return completed;
    }
    
    func changeAllApiCall(sender: UIButton) {
        let taskCollectionPoint = getTaskCollectionPoints()[sender.tag]
        let url = Environment.SERVER_URL + "api/task_collection_point/"+String(taskCollectionPoint.id)+"/bulk_complete/"

        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = APIHeaders.getHeaders() {
            request.headers = headers
        }

        AF.request(request)
            .validate()
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let taskCollectionsNew = try! JSONDecoder().decode([TaskCollection].self, from: value!)
                    self.getTaskCollectionPoints()[sender.tag].taskCollections = taskCollectionsNew
                    self.garbageSummaryList = self.getGarbageSummaryList(taskCollectionPoints: self.getTaskCollectionPoints())
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
//                        self.tableView.reloadRows(at: [ IndexPath(row: sender.tag, section: 0) ], with: .automatic)
                        self.garbageSummaryTable.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsVListUpdate, object: taskCollectionsNew)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @objc
    func toggleAllTasks(sender: UIButton) {
        let taskCollectionPoint = getTaskCollectionPoints()[sender.tag]
        if( isAllCompleted(taskCollectionPoint: taskCollectionPoint)) {
            let confirmAlert = UIAlertController(title: "Incomplete ?", message: "Are you sure you want to incomplete the collection ?", preferredStyle: .alert)
            
            confirmAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                return
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Yes. Incomplete", style: .default, handler: { (action: UIAlertAction!) in
                self.changeAllApiCall(sender: sender)
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
        else {
            self.changeAllApiCall(sender: sender)
        }
    }
    
    func changeTaskStatus(sender: GarbageButton) {
        let taskCollectionPoint = getTaskCollectionPoints()[sender.taskCollectionPointPosition!]
        let taskCollection = taskCollectionPoint.taskCollections[sender.taskPosition!]
        
        let url = Environment.SERVER_URL + "api/task_collection/"+String(taskCollection.id)+"/"
        
        let values = [ "complete": !taskCollection.complete ] as [String : Any?]
                
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
                    let taskCollectionNew = try! JSONDecoder().decode(TaskCollection.self, from: value!)
                    self.getTaskCollectionPoints()[sender.taskCollectionPointPosition!].taskCollections[sender.taskPosition!] = taskCollectionNew
                    self.garbageSummaryList = self.getGarbageSummaryList(taskCollectionPoints: self.getTaskCollectionPoints())
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
//                        self.tableView.reloadRows(at: [IndexPath(row: sender.taskCollectionPointPosition!, section: 0)], with: .automatic)
                        self.garbageSummaryTable.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsVListUpdate, object: [taskCollectionNew])

                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @objc
    func pressed(sender: GarbageButton) {
        let taskCollectionPoint = getTaskCollectionPoints()[sender.taskCollectionPointPosition!]
        let taskCollection = taskCollectionPoint.taskCollections[sender.taskPosition!]
        
        if(taskCollection.complete == true) {
            let confirmAlert = UIAlertController(title: "Incomplete ?", message: "Are you sure you want to incomplete the collection ?", preferredStyle: .alert)
            
            confirmAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                return
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Yes. Incomplete", style: .default, handler: { (action: UIAlertAction!) in
                self.changeTaskStatus(sender: sender)
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
        else {
            changeTaskStatus(sender: sender)
        }
    }
    
    func getGarbageSummaryList(taskCollectionPoints: [TaskCollectionPoint]) -> [GarbageListItem]{
        
        if taskCollectionPoints.count == 0 {
            return []
        }
        
        
        if taskCollectionPoints[0].taskCollections.count == 0 {
            return []
        }
        
        var garbageSummaryMap: [Int: GarbageListItem] = [:]
        
        for tc in taskCollectionPoints[0].taskCollections {
            let garbageSummaryItem = GarbageListItem(garbage: tc.garbage, complete: 0, total: 0)
            garbageSummaryMap[tc.garbage.id] = garbageSummaryItem
        }
        
        for tcp in taskCollectionPoints {
            for tc in tcp.taskCollections {
                if tc.complete {
                    garbageSummaryMap[tc.garbage.id]?.complete += 1
                }
                garbageSummaryMap[tc.garbage.id]?.total += 1
            }
        }
        
        var listToReturn: [GarbageListItem] = []
        
        for (_, garbageSummaryItem) in garbageSummaryMap.enumerated() {
            listToReturn.append(garbageSummaryItem.value)
        }
        
        listToReturn = listToReturn.sorted() { $0.garbage.id < $1.garbage.id }
        
        return listToReturn
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
