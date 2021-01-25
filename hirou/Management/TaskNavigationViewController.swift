//
//  TaskNavigationViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 01/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Mapbox
import Alamofire
import FSPagerView

import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

import Firebase
import FirebaseFirestore

extension TaskNavigationViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.taskCollectionPoints.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "taskCollectionPointPagerCell", at: index) as! TaskCollectionPointPagerCell
        
        let tcp = self.taskCollectionPoints[index]
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
        let taskCollectionPoint = self.taskCollectionPoints[sender.tag]
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
                    self.taskCollectionPoints[sender.tag].taskCollections = taskCollectionsNew
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: taskCollectionsNew)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @objc
    func toggleAllTasks(sender: UIButton) {
        let taskCollectionPoint = self.taskCollectionPoints[sender.tag]
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
        let taskCollectionPoint = self.taskCollectionPoints[sender.taskCollectionPointPosition!]
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
                    self.taskCollectionPoints[sender.taskCollectionPointPosition!].taskCollections[sender.taskPosition!] = taskCollectionNew
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
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

class TaskNavigationViewController: UIViewController, MGLMapViewDelegate, NavigationViewControllerDelegate {
    var id: String = ""
    @IBOutlet weak var mapView: NavigationMapView!
    @IBOutlet weak var collectionView: FSPagerView! {
        didSet {
            self.collectionView.register(UINib(nibName: "TaskCollectionPointPagerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "taskCollectionPointPagerCell")
        }
    }
    
    var selectedTaskCollectionPoint: TaskCollectionPoint!
    var taskCollectionPoints = [TaskCollectionPoint]()
    var annotations = [MGLPointAnnotation]()
    var route:TaskRoute?
    
    private let notificationCenter = NotificationCenter.default
    
    
    @IBOutlet weak var navigationViewContainer: UIView!
    @IBOutlet weak var mapViewContainer: NavigationMapView!
    
    var navigationViewController: NavigationViewController!
    
    let db = Firestore.firestore()
    var locationListener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        
        navigationViewContainer.isHidden = true
        mapViewContainer.isHidden = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.transformer = FSPagerViewTransformer(type: .linear)
        
        let transform = CGAffineTransform(scaleX: 0.8, y: 0.9)
        collectionView.itemSize = collectionView.frame.size.applying(transform)
        collectionView.decelerationDistance = FSPagerView.automaticDistance
        
        let plus = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(zoomIn))
        let minus = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .plain, target: self, action: #selector(zoomOut))
        navigationItem.setLeftBarButtonItems([minus, plus], animated: true)
        
        let completedHiddenSwitch = UISwitch(frame: .zero)
        completedHiddenSwitch.isOn = false
        completedHiddenSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        let switch_display = UIBarButtonItem(customView: completedHiddenSwitch)
        
        let button1 = UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .plain, target: self, action: #selector(goToUserLocation))
        let button2 = UIBarButtonItem(image: UIImage(systemName: "selection.pin.in.out"), style: .plain, target: self, action: #selector(adjustMap))
        navigationItem.setRightBarButtonItems([button1, button2, switch_display], animated: true)
        
        self.id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsVListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsHListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .TaskCollectionPointsHListSelect, object: nil)
        self.getPoints()
    }
    
    @objc
    func zoomIn() {
        if(self.mapView.zoomLevel + 1 <= self.mapView.maximumZoomLevel) {
            self.mapView.setZoomLevel(self.mapView.zoomLevel + 1, animated: true)
        }
    }
    
    @objc
    func zoomOut() {
        if(self.mapView.zoomLevel - 1 >= self.mapView.minimumZoomLevel) {
            self.mapView.setZoomLevel(self.mapView.zoomLevel - 1, animated: true)
        }
    }
    
    @objc
    func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            addPointsTopMap(hideCompleted: true)
            self.notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: true)
        }
        else{
            addPointsTopMap()
            notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: false)
        }
    }
    
    @objc
    func goToUserLocation() {
        let userCoordinate = (mapView.userLocation?.coordinate)!
        mapView.setCenter(userCoordinate, zoomLevel: 18, animated: true)
    }
    
    @objc
    func adjustMap() {
        handleAutomaticZoom()
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsVListUpdate, object: nil)
        notificationCenter.removeObserver(self, name: .TaskCollectionPointsHListSelect, object: nil)
    }

    @objc
    func collectionPointUpdateFromVList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        for tc in tcs {
            for tcp in self.taskCollectionPoints {
                for num in 0...tcp.taskCollections.count-1 {
                    if tcp.taskCollections[num].id == tc.id {
                        tcp.taskCollections[num] = tc
                        for x in annotations {
                            if String(x.coordinate.latitude) == String(tcp.location.latitude) {
                                DispatchQueue.main.async {
                                    self.mapView.removeAnnotation(x)
                                    self.mapView.addAnnotation(x)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        break
                    }
                }
            }
        }
    }
    
    @objc
    func collectionPointSelectFromVList(_ notification: Notification) {
        let tc = notification.object as! TaskCollectionPoint
        for num in 0...self.taskCollectionPoints.count-1 {
            if tc.id == self.taskCollectionPoints[num].id {
                focusPoint(index: num)
            }
        }
    }
    
    func focusPoint(index: Int) {
        mapView.setCenter(self.annotations[index].coordinate, zoomLevel: 18, direction: -1, animated: true)
        mapView.selectAnnotation(self.annotations[index], animated: false, completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.getPoints()
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
                
                self.collectionView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsTopMap(hideCompleted : Bool = false) {
        self.mapView.removeAnnotations(self.annotations)
        self.annotations = []
        
        for cp in self.taskCollectionPoints {
            let annotation = MGLPointAnnotation()
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = cp.name
            //            annotation.subtitle = "\(Double(annotation.coordinate.latitude)), \(Double(annotation.coordinate.longitude))"
            
            if(!cp.getCompleteStatus() || !hideCompleted) {
                annotations.append(annotation)
            }
        }
        
        mapView.addAnnotations(annotations)
        
        self.handleAutomaticZoom()
    }
    
    func handleAutomaticZoom() {
        let annotations = self.annotations
        
        var firstCoordinate: CLLocationCoordinate2D
        
        if mapView.userLocation?.coordinate != nil {
            firstCoordinate = mapView.userLocation!.coordinate
        }
        else {
            firstCoordinate = annotations[0].coordinate
        }
        
        if annotations.count > 0 {
//            let firstCoordinate = annotations[0].coordinate
            
            //Find the southwest and northeast point
            var northEastLatitude = firstCoordinate.latitude
            var northEastLongitude = firstCoordinate.longitude
            var southWestLatitude = firstCoordinate.latitude
            var southWestLongitude = firstCoordinate.longitude
            
            for annotation in annotations {
                let coordinate = annotation.coordinate
                
                northEastLatitude = max(northEastLatitude, coordinate.latitude)
                northEastLongitude = max(northEastLongitude, coordinate.longitude)
                southWestLatitude = min(southWestLatitude, coordinate.latitude)
                southWestLongitude = min(southWestLongitude, coordinate.longitude)
            }
            let verticalMarginInPixels = 250.0
            let horizontalMarginInPixels = 250.0
            
            let verticalMarginPercentage = verticalMarginInPixels/Double(mapView.bounds.size.height)
            let horizontalMarginPercentage = horizontalMarginInPixels/Double(mapView.bounds.size.width)
            
            let verticalMargin = (northEastLatitude-southWestLatitude)*verticalMarginPercentage
            let horizontalMargin = (northEastLongitude-southWestLongitude)*horizontalMarginPercentage
            
            southWestLatitude -= verticalMargin
            southWestLongitude -= horizontalMargin
            
            northEastLatitude += verticalMargin
            northEastLongitude += horizontalMargin
            
            if (southWestLatitude < -85.0) {
                southWestLatitude = -85.0
            }
            if (southWestLongitude < -180.0) {
                southWestLongitude = -180.0
            }
            if (northEastLatitude > 85) {
                northEastLatitude = 85.0
            }
            if (northEastLongitude > 180.0) {
                northEastLongitude = 180.0
            }
            
            mapView.setVisibleCoordinateBounds(MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(southWestLatitude, southWestLongitude), CLLocationCoordinate2DMake(northEastLatitude, northEastLongitude)), animated: true)
        }
    }
    
    func navigate(coordinate: CLLocationCoordinate2D) {
//        navigationViewContainer.isHidden = false
//        mapViewContainer.isHidden = true
        
        var waypoints = [Waypoint]()
        waypoints.append(Waypoint(coordinate: (mapView.userLocation?.coordinate)!))
        
        for (index, i)  in self.annotations.enumerated() {
            waypoints.append(Waypoint(coordinate: i.coordinate, name: self.taskCollectionPoints[index].name))
        }
        
//        waypoints.append(Waypoint(coordinate: coordinate))
        
        let options = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .automobile)
        Directions.shared.calculate(options) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                
                strongSelf.navigationViewContainer.isHidden = false
                strongSelf.mapViewContainer.isHidden = true
                
                let navigationService = MapboxNavigationService(route: route, routeOptions: options, simulating: .never)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                strongSelf.navigationViewController = NavigationViewController(for: route, routeOptions: options, navigationOptions: navigationOptions)
                strongSelf.navigationViewController.delegate = strongSelf
                strongSelf.navigationViewContainer.addSubview(strongSelf.navigationViewController.view)
                
                strongSelf.navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    strongSelf.navigationViewController.view.leadingAnchor.constraint(equalTo: (strongSelf.navigationViewContainer.leadingAnchor), constant: 0),
                    strongSelf.navigationViewController.view.trailingAnchor.constraint(equalTo: (strongSelf.navigationViewContainer.trailingAnchor), constant: 0),
                    strongSelf.navigationViewController.view.topAnchor.constraint(equalTo: (strongSelf.navigationViewContainer.topAnchor), constant: 0),
                    strongSelf.navigationViewController.view.bottomAnchor.constraint(equalTo: (strongSelf.navigationViewContainer.bottomAnchor), constant: 0)
                ])
                strongSelf.navigationViewController.didMove(toParent: strongSelf)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if annotation is MGLUserLocation {
            return false
        }
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        var currentIndex = 0
        for cp in self.taskCollectionPoints {
            if cp.location.latitude == String(annotation.coordinate.latitude) {
                self.selectedTaskCollectionPoint = self.taskCollectionPoints[currentIndex];
                collectionView.selectItem(at: currentIndex, animated: true)
                self.notificationCenter.post(name: .TaskCollectionPointsMapSelect, object: self.taskCollectionPoints[currentIndex])
                break
            }
            currentIndex += 1
        }
//        let origin = (mapView.userLocation?.coordinate)!
//        let coordinate = annotation.coordinate
//        calculateRoute(from: origin, to: coordinate)
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        var currentIndex = 0
        for cp in self.taskCollectionPoints {
            if cp.location.latitude == String(annotation.coordinate.latitude) {
                self.selectedTaskCollectionPoint = self.taskCollectionPoints[currentIndex];
                break
            }
            currentIndex += 1
        }
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if let image = UIImage(named: "truck") {
            mapView.style?.setImage(image, forName: "truck-icon")
        }
        
        locationListener = db.collection("vehicles")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New city: \(diff.document.data()) \(diff.document.documentID)")
                      
                        let latitude = diff.document.data() ["latitude"] as? NSNumber
                        let longitude = diff.document.data() ["longitude"] as? NSNumber
                        
                        let coordinates =  CLLocationCoordinate2D(latitude: Double(truncating: latitude ?? 0) , longitude: Double(truncating: longitude ?? 0));
                        
                        let point = MGLPointAnnotation()
                        point.coordinate = coordinates
                        
                        let source = MGLShapeSource(identifier: diff.document.documentID, shape: point, options: nil)
                        style.addSource(source)
                        
                        let droneLayer = MGLSymbolStyleLayer(identifier: diff.document.documentID, source: source)
                        droneLayer.iconScale = NSExpression(forConstantValue: 0.5)
                        droneLayer.iconImageName = NSExpression(forConstantValue: "truck-icon")
                        droneLayer.iconHaloColor = NSExpression(forConstantValue: UIColor.white)
                        style.addLayer(droneLayer)
                        
                    }
                    if (diff.type == .modified) {
                        print("Modified city: \(diff.document.data()) \(diff.document.documentID)")

//                        TODO :: Check if we can change the source coordinates without deleting and creating a new one
                        
                        if let source = style.source(withIdentifier: diff.document.documentID) {
                            if let droneLayer = style.layer(withIdentifier: diff.document.documentID) {
                                style.removeLayer(droneLayer)
                                style.removeSource(source)
                            }
                        }

                        let latitude = diff.document.data() ["latitude"] as? NSNumber
                        let longitude = diff.document.data() ["longitude"] as? NSNumber

                        let coordinates =  CLLocationCoordinate2D(latitude: Double(truncating: latitude ?? 0) , longitude: Double(truncating: longitude ?? 0));

                        let point = MGLPointAnnotation()
                        point.coordinate = coordinates

                        let source = MGLShapeSource(identifier: diff.document.documentID, shape: point, options: nil)
                        style.addSource(source)

                        let droneLayer = MGLSymbolStyleLayer(identifier: diff.document.documentID, source: source)
                        droneLayer.iconScale = NSExpression(forConstantValue: 0.5)
                        droneLayer.iconImageName = NSExpression(forConstantValue: "truck-icon")
                        droneLayer.iconHaloColor = NSExpression(forConstantValue: UIColor.white)
                        style.addLayer(droneLayer)
                        
                        
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data()) \(diff.document.documentID)")
                        
                        if let source = style.source(withIdentifier: diff.document.documentID) {
                            if let droneLayer = style.layer(withIdentifier: diff.document.documentID) {
                                style.removeLayer(droneLayer)
                                style.removeSource(source)
                            }
                        }
                    }
                }
            }
    }
    
//    // Calculate route to be used for navigation
//    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
//        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
//        let origin = Waypoint(coordinate: origin, name: "Start")
//        let destination = Waypoint(coordinate: destination, name: "Finish")
//
//        // Specify that the route is intended for automobiles avoiding traffic
//        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
//
//        // Generate the route object and draw it on the map
//        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
//            switch result {
//            case .failure(let error):
//                print(error.localizedDescription)
//            case .success(let response):
//                guard let route = response.routes?.first, let _ = self else {
//                    return
//                }
//
////                self.route = route
////                self.routeOptions = routeOptions
//
//                // Draw the route on the map after creating it
//                self!.drawRoute(route: route)
//
//                // Show destination waypoint on the map
//                self?.mapView.showWaypoints(on: route)
//            }
//        }
//    }
    
    func drawRoute(route: Route) {
        guard let routeShape = route.shape, routeShape.coordinates.count > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = routeShape.coordinates
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let editPoint = UIButton(type: .detailDisclosure)
        editPoint.addTarget(self, action: #selector(editPointSegue(sender:)), for: .touchDown)
        return editPoint
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let image = UIImage(systemName: "location")
        let button   = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(navigateToPoint(sender:)), for: .touchDown)
        
        var currentIndex = 0
        for cp in self.taskCollectionPoints {
            if cp.location.latitude == String(annotation.coordinate.latitude) {
                self.selectedTaskCollectionPoint = self.taskCollectionPoints[currentIndex];
                button.tag = currentIndex
                break
            }
            currentIndex += 1
        }
        return button
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            // Set the annotation view’s background color to a value determined by its longitude.
//            let hue = CGFloat(annotation.coordinate.longitude) / 100
//            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
            annotationView!.backgroundColor = UIColor.red
            
            for i in self.taskCollectionPoints {
                if String(i.location.latitude) == String(annotation.coordinate.latitude) {
                    if String(i.location.longitude) == String(annotation.coordinate.longitude) {
                        if i.getCompleteStatus() {
                            annotationView!.backgroundColor = UIColor.gray
                        }
                    }
                }
            }
            
        }
        
        return annotationView
    }
    
    @objc
    func navigateToPoint (sender: UIButton) {
        navigate(coordinate: self.annotations[sender.tag].coordinate)
    }
    
    @objc func editPointSegue(sender: UIButton) {
        self.performSegue(withIdentifier: "editTaskCollectionPoint", sender: self)
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        if(canceled) {
            navigationViewController.willMove(toParent: nil)
            navigationViewController.removeFromParent()
            navigationViewContainer.isHidden = true
            mapViewContainer.isHidden = false
        }
    }

    func navigationViewController(_ navigationViewController: NavigationViewController, waypointStyleLayerWithIdentifier identifier: String, source: MGLSource) -> MGLStyleLayer? {
        
        let waypointStyleLayer = MGLCircleStyleLayer(identifier: identifier, source: source)
        waypointStyleLayer.circleColor = NSExpression(forConstantValue: UIColor.yellow)
        waypointStyleLayer.circleRadius = NSExpression(forConstantValue: 10)
        waypointStyleLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.black)
        waypointStyleLayer.circleStrokeWidth = NSExpression(forConstantValue: 1)
        return waypointStyleLayer
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
