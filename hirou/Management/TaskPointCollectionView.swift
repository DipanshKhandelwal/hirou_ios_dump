//
//  TaskPointCollectionView.swift
//  hirou
//
//  Created by ThuNQ on 5/13/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import Kingfisher

extension TaskNavigationViewController {
    var garbageSummaryList: [GarbageListItem] {
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
                    
                    let list = self.getTaskCollectionPoints()
                    if(list.count > sender.tag) {
                        list[sender.tag].taskCollections = taskCollectionsNew
                    }
//                    DispatchQueue.main.async {
//                        self.clvTask.reloadData()
//                        self.addPointsTopMap()
//                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: taskCollectionsNew)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @objc
    func toggleAllTasks(sender: UIButton) {
        let taskCollectionPoint = getTaskCollectionPoints()[sender.tag]
        if( isAllCompleted(taskCollectionPoint: taskCollectionPoint)) {
            let confirmAlert = UIAlertController(title: "", message: "解除しますか？", preferredStyle: .alert)
            
            confirmAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
                return
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "解除する", style: .default, handler: { (action: UIAlertAction!) in
                self.changeAllApiCall(sender: sender)
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
        else {
            self.changeAllApiCall(sender: sender)
        }
    }
    
    func changeTaskStatus(sender: GarbageLineButton) {
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
//                    self.getTaskCollectionPoints()[sender.taskCollectionPointPosition!].taskCollections[sender.taskPosition!] = taskCollectionNew
//                    DispatchQueue.main.async {
//                        self.clvTask.reloadData()
//                        self.addPointsTopMap()
//                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: [taskCollectionNew])
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @objc
    func pressed(sender: GarbageLineButton) {
        let taskCollectionPoint = self.taskCollectionPoints[sender.taskCollectionPointPosition!]
        let taskCollection = taskCollectionPoint.taskCollections[sender.taskPosition!]
        
        if(taskCollection.complete == true) {
            let confirmAlert = UIAlertController(title: "", message: "解除しますか？", preferredStyle: .alert)
            
            confirmAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
                return
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "解除する", style: .default, handler: { (action: UIAlertAction!) in
                self.changeTaskStatus(sender: sender)
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
        else {
            changeTaskStatus(sender: sender)
        }
    }
    
    @objc private func toggleShowTaskCollection() {
        if isTaskCollectionsHidden {
            animationShowTaskCollections()
        } else {
            animationHideTaskCollections()
        }
    }
}

extension TaskNavigationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getTaskCollectionPoints().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCollectionPointPagerCell", for: indexPath) as! TaskCollectionPointPageCell
        
        let tcp = getTaskCollectionPoints()[index]
        
//        cell.sequence?.text = String(tcp.sequence)
        cell.name?.text = tcp.name
//        cell.memo?.text = tcp.memo
        cell.image.loadImage(urlString: tcp.image, placeholder: UIImage(named: "placeholder"))
        cell.btnReport.addTarget(self, action: #selector(reportAdminAction(_:)), for: .touchDown)
        if tcp.taskCollections.count >= 1 {
            cell.stackGarbage1.arrangedSubviews.forEach { $0.removeFromSuperview() }
            cell.stackGarbage2.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
//            let toggleAllTasksButton = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//            toggleAllTasksButton.tag = index;
            cell.btlToggleAll.tag = index
            cell.btlToggleAll.backgroundColor = isAllCompleted(taskCollectionPoint: tcp) ? UIColor(0xE22B40) : .white
            cell.btlToggleAll.setTitleColor(isAllCompleted(taskCollectionPoint: tcp) ? .white : UIColor(0xE22B40) , for: .normal)
            cell.btlToggleAll.setTitle(isAllCompleted(taskCollectionPoint: tcp) ? "全てを解除" : "全てを選択", for: .normal)
            cell.btlToggleAll.viewBorderWidth = 1
            cell.btlToggleAll.viewBorderColor = isAllCompleted(taskCollectionPoint: tcp) ? .white : UIColor(0xE22B40)
            cell.btlToggleAll.addTarget(self, action: #selector(TaskNavigationViewController.toggleAllTasks(sender:)), for: .touchDown)
            cell.btnInfomation.addTarget(self, action: #selector(toggleShowTaskCollection), for: .touchDown)
//            toggleAllTasksButton.layer.backgroundColor = tcp.getCompleteStatus() ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
//            cell.garbageStack.addArrangedSubview(toggleAllTasksButton)
            var arrButton: [UIView] = []
            for num in 0...tcp.taskCollections.count-1 {
                let taskCollection = tcp.taskCollections[num]
                let garbageItem = garbageSummaryList.first(where: { $0.garbage.id == taskCollection.garbage.id })
                let garbageButton = GarbageLineButton(tc: taskCollection, garbageItem: garbageItem, taskCollectionPointPosition: index, taskPosition: num)
                garbageButton.didClickedButton = { [weak self] sender in
                    self?.pressed(sender: sender)
                }
                arrButton.append(garbageButton)
//                garbageView.addTarget(self, action: #selector(TaskNavigationViewController.pressed(sender:)), for: .touchDown)
                if num < 4 {
                    cell.stackGarbage1.addArrangedSubview(garbageButton)
                } else {
                    cell.stackGarbage2.addArrangedSubview(garbageButton)
                }
            }
            if arrButton.count > 4 {
                arrButton[4].translatesAutoresizingMaskIntoConstraints = false
                arrButton[4].widthAnchor.constraint(equalTo: arrButton[0].widthAnchor, multiplier: 1).isActive = true
            }
        }
        
        cell.layer.cornerRadius = 15
        cell.layer.shadowRadius = 15
        cell.backgroundColor = UIColor.white
        
        let blueView = UIView(frame: .infinite)
        blueView.layer.borderWidth = 3
        blueView.layer.borderColor = UIColor.gray.cgColor
        blueView.layer.cornerRadius = 15

        cell.selectedBackgroundView = blueView
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == clvTask {
            focusPoint(index: clvTask.centerCellIndexPath?.row ?? 0)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        focusPoint(index: indexPath.row)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
