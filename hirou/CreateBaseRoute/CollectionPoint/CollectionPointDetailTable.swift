//
//  CollectionPointDetailTable.swift
//  hirou
//
//  Created by ThuNQ on 6/7/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

extension CollectionPointDetailViewController: CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var minHeightTC: CGFloat {
        return 32
    }
    private var maxHeightTC: CGFloat {
        // maxHeight = heightScreenAvailable - (topViewTable + spacingTableWBottomSheet + minHeightTable)
        return heightScreenAvailable - (24 + 32 + bottomSafeArea)
    }
    private var bottomSafeArea: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    private var heightScreenAvailable: CGFloat {
        return view.bounds.height
    }
    
    @objc func toggleEditTable() {
        isEnableEditTable = !isEnableEditTable
    }
    
    func animationShowCollectionPointTable() {
        btnEditTable.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.heightCollectionPoint.constant = self.maxHeightTC
            self.view.layoutIfNeeded()
        }, completion: { _ in
        })
    }
    
    func animationHideCollectionPointTable() {
        btnEditTable.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.heightCollectionPoint.constant = self.minHeightTC
            self.view.layoutIfNeeded()
        }, completion: { _ in
        })
    }
    
    @objc func animationHeightPoinTable(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self.view)
            var heightTC = heightCollectionPoint.constant + translation.y
            if heightTC <= minHeightTC {
                heightTC = minHeightTC
            } else if heightTC >= maxHeightTC {
                heightTC = maxHeightTC
            }
            self.heightCollectionPoint.constant = heightTC
        case .ended:
            let translation = sender.translation(in: self.view)
            let heightTC = heightCollectionPoint.constant + translation.y
            if heightTC <= maxHeightTC / 2 {
                animationHideCollectionPointTable()
            } else {
                animationShowCollectionPointTable()
            }
        default:
            break
        }
    }

    func setupConnection(){
        let userToken = UserDefaults.standard.string(forKey: UserDefaultsConstants.AUTH_TOKEN)
        let queryItems = [URLQueryItem(name: "token", value: userToken)]
        let socketBaseUrl = Environment.SERVER_SOCKET_URL + "subscribe/base-route/" + baseRouteId + "/"
        var urlComponent = URLComponents(string: socketBaseUrl)!
        urlComponent.queryItems = queryItems
        let finalUrl = urlComponent.url!
        socketConnection = WebSocketConnector(withSocketURL: finalUrl)

        socketConnection?.establishConnection()
        
        socketConnection?.didReceiveError = { error in
            //Handle error here
        }
        
        socketConnection?.didOpenConnection = {
            // Connection opened
        }
        
        socketConnection?.didCloseConnection = {
            // Connection closed
        }
        
        socketConnection?.didReceiveData = { data in
            // Get your data here
        }
        
        socketConnection?.didReceiveMessage = {message in
            print("message", message)
            let dict = convertToDictionary(text: message)
            if let event = dict?[SocketKeys.EVENT] as?String, let sub_event = dict?[SocketKeys.SUB_EVENT] as?String {
                if event == SocketEventTypes.BASE_ROUTE {
                    switch sub_event {
                        case SocketSubEventTypes.REORDER: do {
                            let baseRouteData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                            let route = try! JSONDecoder().decode(BaseRoute.self, from: baseRouteData!)
                            if route.id == Int(self.baseRouteId) {
                                self.updateFromBaseRoute(route: route, notify: true)
                            }
                            break;
                        }

                            default:
                                break;
                        }
                }
                
                else if event == SocketEventTypes.COLLECTION_POINT {
                    switch sub_event {
                        case SocketSubEventTypes.CREATE, SocketSubEventTypes.UPDATE, SocketSubEventTypes.DELETE: do {
                            let baseRouteData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                            let route = try! JSONDecoder().decode(BaseRoute.self, from: baseRouteData!)
                            if route.id == Int(self.baseRouteId) {
                                self.updateFromBaseRoute(route: route, notify: true)
                            }
                            break;
                        }
                        
                        default:
                            break;
                    }
                }
            }
        }
    }
    
    @objc
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            presentLocation = location
        }
    }
    
    func updateLocation() {
        if presentLocation == nil {
            print("Present Location not found :: Location not updated")
            return
        }
        
        let latitude = (presentLocation?.coordinate.latitude)!
        let longitude = (presentLocation?.coordinate.longitude)!
        
        let location2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if(isUserTrackingMode) {
            DispatchQueue.main.async {
                self.mapView.animate(toLocation: location2D)
            }
        }
        
//        self.notificationCenter.post(name: .CollectionPointsPresentUserLocationUpdate, object: location2D)
    }
    
    @objc
    func collectionPointUpdateFromMap(_ notification: Notification) {
        let cp = notification.object as! CollectionPoint
        if self.collectionPoints.count == 0 {
            return
        }
        if(self.collectionPoints.count > 0) {
            for num in 0...self.collectionPoints.count-1 {
                if self.collectionPoints[num].id == cp.id {
                    self.tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: .middle)
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCollectionPoints()
    }
    
    func updateFromBaseRoute(route: BaseRoute, notify: Bool = false) {
        let newCollectionPoints = route.collectionPoints ?? []
        self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
        if notify {
            updatePoints()
//            self.notificationCenter.post(name: .CollectionPointsTableReorder, object: self.collectionPoints)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchCollectionPoints(notify: Bool = false){
        let id = self.baseRouteId
        let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                self.updateFromBaseRoute(route: route, notify: notify)
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
        return self.collectionPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionPointCell", for: indexPath) as! CollectionPointTableViewCell
        let collectionPoint = collectionPoints[indexPath.row]
        cell.collectionPointNameLabel!.text = collectionPoint.name
        cell.collectionPointMemoLabel!.text = collectionPoint.memo
        cell.collectionPointIndexLabel!.text = String(collectionPoint.sequence)
        
        if let image = cell.collectionPointImage {
            image.image = UIImage(named: "placeholder")
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Sound.playInteractionSound()
        focusPoint(index: indexPath.row)
//        self.notificationCenter.post(name: .CollectionPointsTableSelect, object: self.collectionPoints[indexPath.row])
    }
    
    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let fromIndex = fromIndexPath[1]
        let toIndex = to[1]
        
        if fromIndex == toIndex { return }
        
        let updateAlert = UIAlertController(title: "シーケンスの更新 ?", message: "シーケンスを更新してもよろしいですか ?", preferredStyle: .alert)
        
        updateAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let updateAlert = UIAlertController(title: "ポイントを削除 ?", message: "ポイントを削除してもよろしいですか？", preferredStyle: .alert)
            
            updateAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }))
            
            updateAlert.addAction(UIAlertAction(title: "削除", style: .default, handler: { [weak self] (action: UIAlertAction!) in
                self?.deleteCPCall(index: indexPath.row)
            }))
            self.present(updateAlert, animated: true, completion: nil)
        }
    }
    
    func updateList(){
        let baseRouteId = self.baseRouteId
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
                    let baseRoute = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                    self.updateFromBaseRoute(route: baseRoute, notify: true)
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func deleteCPCall(index: Int) {
        let id = self.collectionPoints[index].id
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/collection_point/"+String(id)+"/", method: .delete, headers: headers)
            .validate()
            .responseString { [weak self]
                response in
                switch response.result {
                case .success(let value):
                    print("value", value)
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
}
