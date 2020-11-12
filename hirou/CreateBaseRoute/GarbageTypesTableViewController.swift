//
//  GarbageTypesTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 06/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

protocol GarbageTypesViewControllerDelegate {
    func setSelectedGarbage(selectedGarbageList: [Garbage])
}

class GarbageTypesTableViewController: UITableViewController {
    var delegate: GarbageTypesViewControllerDelegate?
    
    var garbageList = [Garbage]()
    var selectedGarbagelist = [Garbage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AF.request(Environment.SERVER_URL + "api/garbage/", method: .get).validate().response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.garbageList = try! JSONDecoder().decode([Garbage].self, from: value!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                //                completion(nil)
            }
        }
        super.viewWillAppear(animated)
    }
    
    var detailItem: Any? {
        didSet {
            if let detail = detailItem {
                self.selectedGarbagelist = detail as! [Garbage]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
        return self.garbageList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "garbageListCell", for: indexPath)
        let garbage = self.garbageList[indexPath.row]
        cell.textLabel!.text = garbage.name
        cell.accessoryType = UITableViewCell.AccessoryType.none
        for selectedGarbage in self.selectedGarbagelist {
            if selectedGarbage.id == garbage.id {
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.isSelected = true
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        self.selectedGarbagelist.append(self.garbageList[indexPath.row])
        self.delegate?.setSelectedGarbage(selectedGarbageList: self.selectedGarbagelist)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.none
        for (index, value) in self.selectedGarbagelist.enumerated() {
            if self.garbageList[indexPath.row].id == value.id {
                self.selectedGarbagelist.remove(at: index)
            }
        }
        self.delegate?.setSelectedGarbage(selectedGarbageList: self.selectedGarbagelist)
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
