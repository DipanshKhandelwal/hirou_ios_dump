//
//  RouteDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps

class CollectionPointDetailViewController: UIViewController, GMSMapViewDelegate {
    var id: String = ""
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.allowsSelectionDuringEditing = false
        }
    }
    var newMarker: CollectionPointMarker!
    var selectedCollectionPoint: CollectionPoint!
    var collectionPoints = [CollectionPoint]()
    var markers = [CollectionPointMarker]()
    
    let baseRouteId = UserDefaults.standard.string(forKey: "selectedRoute")!
    
    let notificationCenter = NotificationCenter.default
    
    var socketConnection: WebSocketConnector?
    
    var locationManager: CLLocationManager?
    var presentLocation: CLLocation?
    var timer: Timer?
    var selectedIndex: Int?
    
    var isUserTrackingMode: Bool = true
    var isEnableEditTable: Bool {
        set {
            tableView.isEditing = newValue
        }
        get {
            return tableView.isEditing
        }
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
    
    @IBOutlet weak var btnEditTable: UIButton! {
        didSet {
            btnEditTable.addTarget(self, action: #selector(toggleEditTable), for: .touchDown)
        }
    }
    @IBOutlet weak var zoomOutButton: UIButton! {
        didSet {
            zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchDown)
        }
    }
    
    @IBOutlet weak var zoomInButton: UIButton! {
        didSet {
            zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchDown)
        }
    }
    
    @IBOutlet weak var trackUserButton: UIButton! {
        didSet {
            trackUserButton.setBackgroundImage(UIImage(systemName: "location.fill"), for: .normal)
            isUserTrackingMode = true
            trackUserButton.addTarget(self, action: #selector(userTrackingSwitchToggled), for: .touchDown)
        }
    }
    @IBOutlet weak var heightCollectionPoint: NSLayoutConstraint!
    @IBOutlet weak var lineCollectionPointTable: UIView! {
        didSet {
            lineCollectionPointTable.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(animationHeightPoinTable(_:))))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false

        self.id = UserDefaults.standard.string(forKey: "selectedRoute")!
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .CollectionPointsTableSelect, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointReorderFromVList(_:)), name: .CollectionPointsTableReorder, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(presentUserLocationUpdated(_:)), name: .CollectionPointsPresentUserLocationUpdate, object: nil)
        setupConnection()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        timer = Timer.scheduledTimer(withTimeInterval: Constants.updateLocationTimeInterval, repeats: true, block: { _ in self.updateLocation() })
        
        animationShowCollectionPointTable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        socketConnection?.disconnect()
        socketConnection = nil
        AppUtility.lockOrientation(.all)
    }
    
    @IBAction func toggleMapType(_ sender: Any) {
        if mapView.mapType == .satellite {
            mapView.mapType = .normal
        } else {
            mapView.mapType = .satellite
        }
    }

    @objc
    func collectionPointSelectFromVList(_ notification: Notification) {
        let cp = notification.object as! CollectionPoint
        for num in 0...self.collectionPoints.count-1 {
            if cp.id == self.collectionPoints[num].id {
                focusPoint(index: num)
            }
        }
    }
    
    @objc
    func collectionPointReorderFromVList(_ notification: Notification) {
        let cps = notification.object as! [CollectionPoint]
        self.collectionPoints = cps
        DispatchQueue.main.async {
            self.addPointsToMap()
            if((self.selectedCollectionPoint) != nil) {
                for (idx, cp) in self.collectionPoints.enumerated() {
                    if self.selectedCollectionPoint.id == cp.id {
                        self.focusPoint(index: idx)
                    }
                }
            }
        }
    }
    
    func updatePoints() {
        DispatchQueue.main.async {
            self.addPointsToMap()
            if((self.selectedCollectionPoint) != nil) {
                for (idx, cp) in self.collectionPoints.enumerated() {
                    if self.selectedCollectionPoint.id == cp.id {
                        self.focusPoint(index: idx)
                    }
                }
            }
        }
    }
    
    func focusPoint(index: Int) {
        mapView.selectedMarker = self.markers[index]
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: Double(self.collectionPoints[index].location.latitude)!, longitude: Double(self.collectionPoints[index].location.longitude)!))
        mapView.animate(toZoom: 18)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getPoints()
        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
    }
    
    func getPoints() {
        let id = self.id
        let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                let newCollectionPoints = route.collectionPoints ?? []
                self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsToMap(focusLast: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsToMap(focusLast: Bool = false) {
        if((self.newMarker) != nil) {
            self.newMarker.map = nil
        }
        self.newMarker = nil
        self.markers = []
        self.mapView.clear()

        for cp in self.collectionPoints {
            let markerObj = CollectionPointMarker(collectionPoint: cp)
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            markerObj.position = position
            markerObj.title = cp.name
            markerObj.map = mapView
            self.markers.append(markerObj)
        }

        
        DispatchQueue.main.async {
            if let selectedIndex = self.selectedIndex, selectedIndex < self.markers.count {
                self.focusPoint(index: selectedIndex)
                self.selectedIndex = nil
            } else if(focusLast && !self.markers.isEmpty){
                self.focusPoint(index: self.markers.count-1)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        Sound.playInteractionSound()
        if marker.title == "New Collection Point" {
            return false
        }

        if(marker is CollectionPointMarker) {
            let ann = marker as! CollectionPointMarker
            let annCpId = ann.collectionPoint.id
            for (index, cp) in self.collectionPoints.enumerated() {
                if annCpId == cp.id {
                    self.selectedCollectionPoint = self.collectionPoints[index];
                    self.notificationCenter.post(name: .CollectionPointsMapSelect, object: self.collectionPoints[index])
                    break
                }
            }
        }
        return false
    }

    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("marker.position.longitude", marker.position.longitude)
        print("marker.position.latitude", marker.position.latitude)
        let a = marker as! CollectionPointMarker
        print("a.collectionPoint", a.collectionPoint.name, a.collectionPoint.id, a.collectionPoint.sequence)
        
        if(a.collectionPoint.id == -1) {
            callAddPointSegue()
        }else {
            callEditPointSegue()
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        if(self.newMarker != nil) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            self.newMarker.position = position
            CATransaction.commit()
            return
        }
        
        let lat = coordinate.latitude
        let long = coordinate.longitude
        let loc = Location(latitude: String(lat), longitude: String(long))!
        let seq = self.collectionPoints.count + 1
        
        let marker = CollectionPointMarker(collectionPoint: CollectionPoint(id: -1, name: "", address: "", memo: "", route: Int(self.id) ?? -1, location: loc, sequence: seq, image: "")!)
        marker.title = "New Collection Point"
        marker.position = position
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.isDraggable = true
        marker.isTappable = true
        marker.map = mapView
        
        self.newMarker = marker
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: 60, height:30));
        stack.axis = .horizontal
        stack.alignment = .center
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.textAlignment = .center
        label.text = String((marker as! CollectionPointMarker).collectionPoint.sequence)
        stack.addArrangedSubview(label)
        
        if marker.title == "New Collection Point" {
            let addPoint = UIButton(type: .contactAdd)
            stack.addArrangedSubview(addPoint)
            
        } else {
            if(marker is CollectionPointMarker) {
                let ann = marker as! CollectionPointMarker
                let annCpId = ann.collectionPoint.id
                for (currentIndex, cp) in self.collectionPoints.enumerated() {
                    if annCpId == cp.id {
                        self.selectedCollectionPoint = self.collectionPoints[currentIndex];
                        break
                    }
                }
                let editPoint = UIButton(type: .detailDisclosure)
                editPoint.frame.size = CGSize(width: 6, height: 6)
                stack.addArrangedSubview(editPoint)
            }
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height:30))
        view.translatesAutoresizingMaskIntoConstraints = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
        view.backgroundColor = .clear
        return view
    }
    
    func callEditPointSegue() {
        self.performSegue(withIdentifier: "editCollectionPoint", sender: self)
    }
    
    func callAddPointSegue() {
        self.performSegue(withIdentifier: "addCollectionPoint", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            controller.detailItem = self.newMarker.collectionPoint
        }
        
        if segue.identifier == "editCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            controller.detailItem = self.selectedCollectionPoint
        }
    }
}
