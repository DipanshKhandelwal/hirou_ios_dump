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
        
        cell.garbageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cell.garbageStack.spacing = 10
        cell.garbageStack.axis = .horizontal
        cell.garbageStack.distribution = .fillEqually
        
        let toggleAllTasksButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toggleAllTasksButton.tag = index;
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
            
            let garbageView = GarbageButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), taskCollectionPointPosition: index, taskPosition: num)
            garbageView.addTarget(self, action: #selector(TaskNavigationViewController.pressed(sender:)), for: .touchDown)
            garbageView.layer.backgroundColor = taskCollection.complete ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
            garbageView.layer.borderWidth = 2
            garbageView.layer.borderColor = UIColor.systemBlue.cgColor
            garbageView.layer.cornerRadius = 10
            garbageView.setTitle(String(taskCollection.garbage.name.prefix(1)), for: .normal)
            garbageView.titleLabel?.font = garbageView.titleLabel?.font.withSize(15)
            garbageView.setTitleColor(.black, for: .normal)
            cell.garbageStack.addArrangedSubview(garbageView)
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
                        self.collectionView.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: taskCollectionsNew)
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
                        self.collectionView.reloadData()
                    }
                    self.notificationCenter.post(name: .TaskCollectionPointsHListUpdate, object: [taskCollectionNew])

                case .failure(let error):
                    print(error)
                }
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
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var collectionView: FSPagerView! {
        didSet {
            self.collectionView.register(UINib(nibName: "TaskCollectionPointPagerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "taskCollectionPointPagerCell")
        }
    }
    
    var selectedTaskCollectionPoint: TaskCollectionPoint!
    var taskCollectionPoints = [TaskCollectionPoint]()
    var annotations = [MGLPointAnnotation]()
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.transformer = FSPagerViewTransformer(type: .linear)
        
        let transform = CGAffineTransform(scaleX: 0.8, y: 0.9)
        collectionView.itemSize = collectionView.frame.size.applying(transform)
        collectionView.decelerationDistance = FSPagerView.automaticDistance
        
        let button1 = UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .plain, target: self, action: #selector(goToUserLocation))
        let button2 = UIBarButtonItem(image: UIImage(systemName: "selection.pin.in.out"), style: .plain, target: self, action: #selector(adjustMap))
        navigationItem.setRightBarButtonItems([button1, button2], animated: true)
        
        self.id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsVListUpdate, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .TaskCollectionPointsHListSelect, object: nil)
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
        self.getPoints()
    }
    
    func getPoints() {
        let id = self.id
        let url = Environment.SERVER_URL + "api/task_route/"+String(id)+"/"
        AF.request(url, method: .get).response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                let newCollectionPoints = route.taskCollectionPoints
                self.taskCollectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsTopMap()
                
                self.collectionView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsTopMap() {
        self.mapView.removeAnnotations(self.annotations)
        self.annotations = []
        
        for cp in self.taskCollectionPoints {
            let annotation = MGLPointAnnotation()
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = cp.name
            //            annotation.subtitle = "\(Double(annotation.coordinate.latitude)), \(Double(annotation.coordinate.longitude))"
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        
        self.handleAutomaticZoom()
    }
    
    func handleAutomaticZoom() {
        let annotations = self.annotations
        let firstCoordinate = (mapView.userLocation?.coordinate)!
        
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
        var waypoints = [Waypoint]()
        waypoints.append(Waypoint(coordinate: (mapView.userLocation?.coordinate)!))
        waypoints.append(Waypoint(coordinate: coordinate))
        
        let options = NavigationRouteOptions(waypoints: waypoints)
        Directions.shared.calculate(options) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                
                let navigationService = MapboxNavigationService(route: route, routeOptions: options, simulating: .never)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: route, routeOptions: options, navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                
                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editTaskCollectionPoint" {
            let controller = (segue.destination as! TaskCollectionsTableViewController)
            controller.detailItem = self.selectedTaskCollectionPoint
        }
    }

}
