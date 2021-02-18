//
//  CollectionPointMasterViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class CollectionPointTableViewCell : UITableViewCell {
    @IBOutlet weak var collectionPointIndexLabel: UILabel!
    @IBOutlet weak var collectionPointNameLabel: UILabel!
    @IBOutlet weak var collectionPointMemoLabel: UILabel!
    @IBOutlet weak var collectionPointImage: UIImageView!
}

class CollectionPointMasterViewController: UITableViewController {
    
    var detailViewController: CollectionPointDetailViewController? = nil
    var collectionPoints = [CollectionPoint]()
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //        navigationItem.leftBarButtonItem = editButtonItem
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CollectionPointDetailViewController
        }
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromMap(_:)), name: .CollectionPointsMapSelect, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointsUpdated(_:)), name: .CollectionPointsUpdated, object: nil)

    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .CollectionPointsMapSelect, object: nil)
        notificationCenter.removeObserver(self, name: .CollectionPointsUpdated, object: nil)
    }
    
    @objc
    func collectionPointsUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.fetchCollectionPoints()
        }
    }
    
    @objc
    func collectionPointUpdateFromMap(_ notification: Notification) {
        let cp = notification.object as! CollectionPoint
        if self.collectionPoints.count == 0 {
            return
        }
        for num in 0...self.collectionPoints.count-1 {
            if self.collectionPoints[num].id == cp.id {
                self.tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: .middle)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        fetchCollectionPoints()
        super.viewWillAppear(animated)
    }
    
    func fetchCollectionPoints(notify: Bool = false){
        let id = UserDefaults.standard.string(forKey: "selectedRoute")!
        let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                let newCollectionPoints = route.collectionPoints
                self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                if notify {
                    self.notificationCenter.post(name: .CollectionPointsTableReorder, object: self.collectionPoints)
                }
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
        return self.collectionPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionPointCell", for: indexPath) as! CollectionPointTableViewCell
        let collectionPoint = collectionPoints[indexPath.row]
        cell.collectionPointNameLabel!.text = collectionPoint.name
        cell.collectionPointMemoLabel!.text = collectionPoint.memo
        cell.collectionPointIndexLabel!.text = String(collectionPoint.sequence)
        
        if let image = cell.collectionPointImage {
            if collectionPoint.image != nil {
                DispatchQueue.global().async { [] in
                    let url = NSURL(string: collectionPoint.image!)! as URL
                    if let imageData: NSData = NSData(contentsOf: url) {
                        DispatchQueue.main.async {
                            image.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.notificationCenter.post(name: .CollectionPointsTableSelect, object: self.collectionPoints[indexPath.row])
    }
    
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
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let fromIndex = fromIndexPath[1]
        let toIndex = to[1]
        
        if fromIndex == toIndex { return }
        
        let updateAlert = UIAlertController(title: "Update sequence ?", message: "Are you sure you want to update the sequence ?", preferredStyle: .alert)
        
        updateAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Update sequence cancelled by the user.")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        
        updateAlert.addAction(UIAlertAction(title: "Yes. Update", style: .default, handler: { (action: UIAlertAction!) in
            let cp: CollectionPoint = self.collectionPoints[fromIndex]
            if(fromIndex < toIndex) {
                (fromIndex...toIndex-1).forEach { index in
                    self.collectionPoints[index] = self.collectionPoints[index+1]
                }
            }
            else {
                (toIndex+1...fromIndex).reversed().forEach { index in
                    self.collectionPoints[index] = self.collectionPoints[index-1]
                }
            }
            self.collectionPoints[toIndex] = cp
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.updateList()
        }))
        self.present(updateAlert, animated: true, completion: nil)
    }
    
    func updateList(){
        let baseRouteId = UserDefaults.standard.string(forKey: "selectedRoute")!
        var array = [String]()
        for element in self.collectionPoints { array.append(String(element.id)) }
        let parameters: [String: [String]] = [
            "points": array
        ]
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/base_route/"+String(baseRouteId)+"/reorder_points/", method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let newCollectionPoints = try! JSONDecoder().decode([CollectionPoint].self, from: value!)
                    self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                    self.notificationCenter.post(name: .CollectionPointsTableReorder, object: self.collectionPoints)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
}
