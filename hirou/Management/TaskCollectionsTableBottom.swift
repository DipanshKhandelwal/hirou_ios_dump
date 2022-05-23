//
//  TaskCollections.swift
//  hirou
//
//  Created by ThuNQ on 5/13/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
	
extension TaskNavigationViewController {
        
    func configureView() {
        if let detail = selectedTaskCollectionPoint {
            self.taskCollections = detail.taskCollections
            DispatchQueue.main.async {
                if (self.tbvTaskCollection != nil) {
                    self.tbvTaskCollection.reloadData()
//                    self.updateCollectionStack()
                }
            }
        }
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
                        self.tbvTaskCollection.reloadRows(at: [ IndexPath(row: position, section: 0) ], with: .automatic)
                    }
                    NotificationCenter.default.post(name: .TaskCollectionPointsHListUpdate, object: [taskCollection])
                case .failure(let error):
                    print(error)
                }
        }
    }
}

extension TaskNavigationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.taskCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath) as! TaskCollectionsCell
        
        let row = indexPath.row
        let taskCollection = self.taskCollections[indexPath.row]
        print("tableView: \(taskCollection.dictionary ?? [:])")
        cell.garbageLabel!.text = taskCollection.garbage.name
        cell.pickupTimeLabel!.text = taskCollection.timestamp ?? "無し"
        
        cell.collectionSwitch.isOn = taskCollection.complete
        cell.collectionSwitch.tag = row
        cell.collectionSwitch!.addTarget(self, action: #selector(switchToggle(_:)), for: .valueChanged)
        return cell
    }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
