//
//  TaskNavigationViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 01/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import FSPagerView

extension TaskNavigationViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return getTaskCollectionPoints().count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "taskCollectionPointPagerCell", at: index) as! TaskCollectionPointPagerCell
        
        let tcp = getTaskCollectionPoints()[index]
        
        cell.sequence?.text = String(tcp.sequence)
        cell.name?.text = tcp.name
        cell.memo?.text = tcp.memo
        
        cell.image?.image = UIImage(systemName: "house")
        DispatchQueue.global().async { [] in
            let url = NSURL(string: tcp.image)! as URL
            if let imageData: NSData = NSData(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.image?.image = UIImage(data: imageData as Data)
                }
            }
        }
        
        if tcp.taskCollections.count >= 1 {
            cell.garbageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            cell.garbageStack.spacing = 10
            cell.garbageStack.axis = .horizontal
            cell.garbageStack.distribution = .fillEqually
            
            let toggleAllTasksButton = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            toggleAllTasksButton.tag = index;
            toggleAllTasksButton.addTarget(self, action: #selector(TaskNavigationViewController.toggleAllTasks(sender:)), for: .touchDown)
            toggleAllTasksButton.layer.backgroundColor = tcp.getCompleteStatus() ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
            cell.garbageStack.addArrangedSubview(toggleAllTasksButton)
            
            for num in 0...tcp.taskCollections.count-1 {
                let taskCollection = tcp.taskCollections[num];
                let garbageView = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), taskCollectionPointPosition: index, taskPosition: num, taskCollection: taskCollection)
                garbageView.addTarget(self, action: #selector(TaskNavigationViewController.pressed(sender:)), for: .touchDown)
                cell.garbageStack.addArrangedSubview(garbageView)
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
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.addPointsTopMap()
                    }
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
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.addPointsTopMap()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: [taskCollectionNew])
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @objc
    func pressed(sender: GarbageButton) {
        let taskCollectionPoint = self.taskCollectionPoints[sender.taskCollectionPointPosition!]
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
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        focusPoint(index: targetIndex)
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        focusPoint(index: index)
    }
}

//class TaskNavigationViewController: UIViewController, MGLMapViewDelegate, NavigationViewControllerDelegate {
class TaskNavigationViewController: UIViewController, GMSMapViewDelegate {
    var id: String = ""
    
    @IBOutlet weak var usersCountText: UILabel!
//    @IBOutlet weak var mapView: NavigationMapView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var collectionView: FSPagerView! {
        didSet {
            self.collectionView.register(UINib(nibName: "TaskCollectionPointPagerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "taskCollectionPointPagerCell")
        }
    }
    
    var selectedTaskCollectionPoint: TaskCollectionPoint!
    var taskCollectionPoints = [TaskCollectionPoint]()
    
//    var annotations = [TaskCollectionPointPointAnnotation]()
    var markers = [TaskCollectionPointMarker]()
    
    var userLocationMarkers = [UserLocationMarker]()
    var route:TaskRoute?
    var hideCompleted: Bool = false
    var isUserTrackingMode: Bool = true
        
    private let notificationCenter = NotificationCenter.default
    
    let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.USER_ID)

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.transformer = FSPagerViewTransformer(type: .linear)
        
        let transform = CGAffineTransform(scaleX: 0.8, y: 0.9)
        collectionView.itemSize = collectionView.frame.size.applying(transform)
        collectionView.decelerationDistance = FSPagerView.automaticDistance
                
        let completedHiddenSwitch = UISwitch(frame: .zero)
        completedHiddenSwitch.isOn = false
        completedHiddenSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        let switch_display = UIBarButtonItem(customView: completedHiddenSwitch)

        navigationItem.setRightBarButtonItems([switch_display], animated: true)
        
        self.id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsVListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsHListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .TaskCollectionPointsHListSelect, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideCompletedTriggered(_:)), name: .TaskCollectionPointsHideCompleted, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdate(_:)), name: .TaskCollectionPointsUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(locationsUpdated(_:)), name: .TaskCollectionPointsUserLocationsUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(presentUserLocationUpdated(_:)), name: .TaskCollectionPointsPresentUserLocationUpdate, object: nil)

        self.getPoints()
    }
    @IBOutlet weak var trackUserButton: UIButton! {
        didSet {
            trackUserButton.setBackgroundImage(UIImage(systemName: "location.fill"), for: .normal)
            isUserTrackingMode = true
            trackUserButton.addTarget(self, action: #selector(userTrackingSwitchToggled), for: .touchDown)
        }
    }
    
    @objc
    func userTrackingSwitchToggled() {
        if !isUserTrackingMode {
            isUserTrackingMode = true
            trackUserButton.setBackgroundImage(UIImage(systemName: "location.fill"), for: .normal)
        }
        else{
            isUserTrackingMode = false
            trackUserButton.setBackgroundImage(UIImage(systemName: "location"), for: .normal)
        }
    }
    
    @IBOutlet weak var zoomOutButton: UIButton! {
        didSet {
            zoomOutButton.setBackgroundImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left.circle"), for: .normal)
            zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchDown)
        }
    }
    
    @IBOutlet weak var zoomInButton: UIButton! {
        didSet {
            zoomInButton.setBackgroundImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle"), for: .normal)
            zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchDown)
        }
    }
    
    func getTaskCollectionPoints () -> [TaskCollectionPoint] {
        if(hideCompleted) {
            return self.taskCollectionPoints.filter { !$0.getCompleteStatus() }
        }
        return self.taskCollectionPoints
    }

    @objc
    func zoomIn() {
        let zoom = self.mapView.camera.zoom
        if(zoom + 1 <= self.mapView.maxZoom) {
            self.mapView.animate(toZoom: zoom + 1)
        }
    }
    
    @objc
    func zoomOut() {
        let zoom = self.mapView.camera.zoom
        if(zoom - 1 >= self.mapView.minZoom) {
            self.mapView.animate(toZoom: zoom - 1)
        }
    }
    
    @objc
    func presentUserLocationUpdated(_ notification: Notification) {
        let newUserLocation = notification.object as! CLLocationCoordinate2D
        if(isUserTrackingMode) {
            DispatchQueue.main.async {
                self.mapView.animate(toLocation: newUserLocation)
            }
        }
    }
    
    @objc
    func locationsUpdated(_ notification: Notification) {
        let newUserLocations = notification.object as! [UserLocation]
        
        DispatchQueue.main.async {
            self.userLocationMarkers.forEach {userLocationMarker in
                if String(userLocationMarker.userLocation.id) == self.userId { return }
                userLocationMarker.map = nil
            }
        }
        
        DispatchQueue.main.async {
            self.usersCountText?.text = String(newUserLocations.count)
        }

        DispatchQueue.main.async {
            newUserLocations.forEach { userLocation in
                if String(userLocation.id) == self.userId {
                    return
                }

                let lat = Double(userLocation.location.latitude)!
                let long = Double(userLocation.location.longitude)!
                let position =  CLLocationCoordinate2D(latitude: lat , longitude: long);
                let markerObj = UserLocationMarker(userLocation: userLocation)
                markerObj.position = position
                
                let markerIcon = UIImage(named: "truck")
                markerObj.icon = markerIcon

                markerObj.map = self.mapView
                self.userLocationMarkers.append(markerObj)
            }
        }
    }
    
    @objc
    func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            self.notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: true)
        }
        else{
            notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: false)
        }
    }
    
    @objc
    func hideCompletedTriggered(_ notification: Notification) {
        let status = notification.object as! Bool
        hideCompletedFunc(hideCompleted: status)
    }
    
    
    func hideCompletedFunc(hideCompleted : Bool = false) {
        self.hideCompleted = hideCompleted
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.addPointsTopMap()
        }
    }

    @objc
    func collectionPointUpdateFromVList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        for tc in tcs {
            
            for tcp in self.taskCollectionPoints {
                
                for (num, _) in tcp.taskCollections.enumerated() {
                    if tcp.taskCollections[num].id == tc.id {
                        tcp.taskCollections[num] = tc
//                        for x in markers {
//                            if x.taskCollectionPoint.id == tcp.id {
//                                DispatchQueue.main.async {
//                                    if(x.taskCollectionPoint.getCompleteStatus()) {
//                                        if(!self.hideCompleted) {
//                                            x.icon = GMSMarker.markerImage(with: UIColor.gray)
//                                        }
//                                        else {
//                                            x.map = nil
//                                        }
//                                    } else {
//                                        x.icon = GMSMarker.markerImage(with: nil)
//                                    }
//                                }
//                            }
//                        }
//                        DispatchQueue.main.async {
//                            self.collectionView.reloadData()
//                        }
                        break
                    }
                }
                
            }
        }
        
        DispatchQueue.main.async {
            self.addPointsTopMap()
            self.collectionView.reloadData()
        }
        
    }
    
    @objc
    func collectionPointUpdate(_ notification: Notification) {
        let tcPoints = notification.object as! [TaskCollectionPoint]
        self.taskCollectionPoints = tcPoints
        DispatchQueue.main.async {
            self.addPointsTopMap()
            self.collectionView.reloadData()
        }
    }
    
    @objc
    func collectionPointSelectFromVList(_ notification: Notification) {
        let tc = notification.object as! TaskCollectionPoint
        let data = getTaskCollectionPoints()
        
        for num in 0...data.count-1 {
            if tc.id == data[num].id {
                focusPoint(index: num)
            }
        }
    }
    
    func focusPoint(index: Int) {
        mapView.selectedMarker = self.markers[index]
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: Double(self.taskCollectionPoints[index].location.latitude)!, longitude: Double(self.taskCollectionPoints[index].location.longitude)!))
        mapView.animate(toZoom: 18)
        
        collectionView.layoutIfNeeded()
        collectionView.reloadData()
        
        if let numberOfItems = collectionView.dataSource?.numberOfItems(in: collectionView), numberOfItems > 0 {
            if(numberOfItems > index) {
                collectionView.scrollToItem(at: index, animated: true)
            }
        }
    }
    
    func getPoints() {
        let id = self.id
        let url = Environment.SERVER_URL + "api/task_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                let newCollectionPoints = self.route!.taskCollectionPoints
                self.taskCollectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsTopMap()
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsTopMap() {
        self.markers = []
        self.mapView.clear()
        
        for cp in getTaskCollectionPoints() {
            let markerObj = TaskCollectionPointMarker(taskCollectionPoint: cp)
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            markerObj.position = position
            markerObj.title = cp.name
            markerObj.map = mapView
            
            if(cp.getCompleteStatus()) {
                if(!self.hideCompleted) {
                    markerObj.icon = GMSMarker.markerImage(with: UIColor.gray)
                    self.markers.append(markerObj)
                }
                else {
                    markerObj.map = nil
                }
            }
            else {
                self.markers.append(markerObj)
            }
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        Sound.playInteractionSound()

        if marker is TaskCollectionPointMarker {
            let ann = marker as! TaskCollectionPointMarker
            let annTcpId = ann.taskCollectionPoint.id

            for (index, cp) in self.taskCollectionPoints.enumerated() {
                if cp.id == annTcpId {
                    self.selectedTaskCollectionPoint = self.taskCollectionPoints[index];
                    
                    self.notificationCenter.post(name: .TaskCollectionPointsMapSelect, object: self.taskCollectionPoints[index])
                    
                    collectionView.layoutIfNeeded()
                    collectionView.reloadData()
                    if let numberOfItems = collectionView.dataSource?.numberOfItems(in: collectionView), numberOfItems > 0 {
                        if(numberOfItems > index) {
                            collectionView.scrollToItem(at: index, animated: true)
                        }
                    }
                    
                    break
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        editPointSegue()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: 60, height:30));
        stack.axis = .horizontal
        stack.alignment = .center
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.textAlignment = .center
        label.text = String((marker as! TaskCollectionPointMarker).taskCollectionPoint.sequence)
        stack.addArrangedSubview(label)
        
        if(marker is TaskCollectionPointMarker) {
            let ann = marker as! TaskCollectionPointMarker
            let annCpId = ann.taskCollectionPoint.id
            for (currentIndex, cp) in self.taskCollectionPoints.enumerated() {
                if annCpId == cp.id {
                    self.selectedTaskCollectionPoint = self.taskCollectionPoints[currentIndex];
                    break
                }
            }
            let editPoint = UIButton(type: .detailDisclosure)
            editPoint.frame.size = CGSize(width: 6, height: 6)
            stack.addArrangedSubview(editPoint)
        }
        
        return stack
    }
    
    func editPointSegue() {
        self.performSegue(withIdentifier: "editTaskCollectionPoint", sender: self)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editTaskCollectionPoint" {
            let controller = (segue.destination as! TaskCollectionsTableViewController)
            controller.detailItem = self.selectedTaskCollectionPoint
            controller.route = self.route
        }
    }

}
