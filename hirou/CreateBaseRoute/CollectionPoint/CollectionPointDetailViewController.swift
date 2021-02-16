//
//  RouteDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Mapbox
import Alamofire

class CollectionPointDetailViewController: UIViewController, MGLMapViewDelegate {
    
    var id: String = ""
    @IBOutlet var mapView: MGLMapView!
    var newAnnotation: CollectionPointPointAnnotation!
    var selectedCollectionPoint: CollectionPoint!
    var collectionPoints = [CollectionPoint]()
    var annotations = [CollectionPointPointAnnotation]()
    
    var gestures : [UIGestureRecognizer] = []
    
    private let notificationCenter = NotificationCenter.default
    
    var userLocationButton: UIBarButtonItem? = nil;
    var allLayoutButton: UIBarButtonItem? = nil;
    var navigateButton: UIBarButtonItem? = nil;

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithCourse
        mapView.showsUserHeadingIndicator = true
//        mapView.zoomLevel = 22
        
        let plus = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(zoomIn))
        let minus = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .plain, target: self, action: #selector(zoomOut))
        
        let lockUserTracking = UISwitch(frame: .zero)
        lockUserTracking.isOn = true
        lockUserTracking.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        let switch_display = UIBarButtonItem(customView: lockUserTracking)
        
        navigationItem.setLeftBarButtonItems([minus, plus, switch_display], animated: true)

        self.id = UserDefaults.standard.string(forKey: "selectedRoute")!
        
        self.userLocationButton = UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .plain, target: self, action: #selector(goToUserLocation))
        self.allLayoutButton = UIBarButtonItem(image: UIImage(systemName: "selection.pin.in.out"), style: .plain, target: self, action: #selector(self.handleAutomaticZoom))
        self.navigateButton = UIBarButtonItem(image: UIImage(systemName: "car"), style: .plain, target: self, action: #selector(self.followVehicle))
        navigationItem.setRightBarButtonItems([self.userLocationButton!, self.allLayoutButton!, self.navigateButton!], animated: true)
        
        self.gestures = self.mapView.gestureRecognizers ?? []
        toggleGestures(disable: true)
        self.allLayoutButton?.isEnabled = false
        self.userLocationButton?.isEnabled = false
        self.navigateButton?.isEnabled = false
        
        self.addNewPointGesture()
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .CollectionPointsTableSelect, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointReorderFromVList(_:)), name: .CollectionPointsTableReorder, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointsUpdated(_:)), name: .CollectionPointsUpdated, object: nil)

    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .CollectionPointsTableSelect, object: nil)
        notificationCenter.removeObserver(self, name: .CollectionPointsTableReorder, object: nil)
        notificationCenter.removeObserver(self, name: .CollectionPointsUpdated, object: nil)
     }
    
    @objc
    func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            toggleGestures(disable: true)
            self.addNewPointGesture()
            mapView.userTrackingMode = .followWithCourse
            mapView.showsUserHeadingIndicator = true
            
            self.allLayoutButton?.isEnabled = false
            self.userLocationButton?.isEnabled = false
            self.navigateButton?.isEnabled = false
        }
        else{
            toggleGestures(disable: false)
            
            self.allLayoutButton?.isEnabled = true
            self.userLocationButton?.isEnabled = true
            self.navigateButton?.isEnabled = true
        }
    }
    
    func toggleGestures(disable: Bool = true) {
        for gestureRecognizer in self.gestures {
            if(disable){
                mapView.removeGestureRecognizer(gestureRecognizer)
            }
            else {
                mapView.addGestureRecognizer(gestureRecognizer)
            }
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
        self.addPointsTopMap()
    }
    
    @objc
    func collectionPointsUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.getPoints()
        }
    }
    
    func focusPoint(index: Int) {
        mapView.setCenter(self.annotations[index].coordinate, zoomLevel: 18, direction: -1, animated: true)
        mapView.selectAnnotation(self.annotations[index], animated: false, completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getPoints()
    }
    
    func addNewPointGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleNewPointTap(_:)))
        mapView?.addGestureRecognizer(gesture)
    }
    
    func getPoints() {
        let id = self.id
        let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                let newCollectionPoints = route.collectionPoints
                self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsTopMap()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsTopMap(autoZoom: Bool = false) {
        self.mapView.removeAnnotations(self.annotations)
        if self.newAnnotation != nil {
            self.mapView.removeAnnotation(self.newAnnotation)
        }
        self.annotations = []
        
        for cp in self.collectionPoints {
            let annotation = CollectionPointPointAnnotation(collectionPoint: cp)
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.title = cp.name
            //            annotation.subtitle = "\(Double(annotation.coordinate.latitude)), \(Double(annotation.coordinate.longitude))"
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        
        if autoZoom {
            self.handleAutomaticZoom()
        }
        // Center the map on the annotation.
        //        mapView.setCenter(annotations[0].coordinate, zoomLevel: 14, animated: false)
        
        // Pop-up the callout view.
        //        mapView.selectAnnotation(annotations[0], animated: true, completionHandler: nil)
    }
    
    @objc
    func goToUserLocation() {
        guard let userCoordinate = mapView.userLocation?.coordinate else { return }
        mapView.setCenter(userCoordinate, zoomLevel: 18, animated: true)
    }
    
    @objc func handleAutomaticZoom() {
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
    
    @objc
    func followVehicle() {
        mapView.userTrackingMode = .followWithCourse
    }
    
    @objc func handleNewPointTap(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let spot = gesture.location(in: mapView)
        guard let location = mapView?.convert(spot, toCoordinateFrom: mapView) else { return }
        
        if (self.newAnnotation != nil) {
            mapView.removeAnnotation(self.newAnnotation)
        }
        
        let lat = location.latitude
        let long = location.longitude
        let loc = Location(latitude: String(lat), longitude: String(long))!
        let seq = self.collectionPoints.count + 1
        
        self.newAnnotation = CollectionPointPointAnnotation(collectionPoint: CollectionPoint(id: -1, name: "", address: "", memo: "", route: Int(self.id) ?? -1, location: loc, sequence: seq, image: "")!)
        
        self.newAnnotation.coordinate = location
        self.newAnnotation.title = "New Collection Point"
        mapView.addAnnotation(self.newAnnotation)
        mapView.selectAnnotation(self.newAnnotation, animated: true, completionHandler: nil)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if annotation is MGLUserLocation {
            return false
        }
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if annotation.title == "New Collection Point" {
            return
        }
        var currentIndex = 0
        for cp in self.collectionPoints {
            if cp.location.latitude == String(annotation.coordinate.latitude) {
                self.selectedCollectionPoint = self.collectionPoints[currentIndex];
                self.notificationCenter.post(name: .CollectionPointsMapSelect, object: self.collectionPoints[currentIndex])
                break
            }
            currentIndex += 1
        }
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        label.text = String((annotation as! CollectionPointPointAnnotation).collectionPoint.sequence)
        return label
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        if annotation.title == "New Collection Point" {
            let addPoint = UIButton(type: .contactAdd)
            addPoint.addTarget(self, action: #selector(addPointSegue(sender:)), for: .touchDown)
            return addPoint
        } else {
            var currentIndex = 0
            for cp in self.collectionPoints {
                if cp.location.latitude == String(annotation.coordinate.latitude) {
                    self.selectedCollectionPoint = self.collectionPoints[currentIndex];
                    print("selected", self.collectionPoints[currentIndex].name)
                    break
                }
                currentIndex += 1
            }
            
            let editPoint = UIButton(type: .detailDisclosure)
            editPoint.addTarget(self, action: #selector(editPointSegue(sender:)), for: .touchDown)
            return editPoint
        }
    }
    
    @objc func addPointSegue(sender: UIButton) {
        self.performSegue(withIdentifier: "addCollectionPoint", sender: self)
    }
    
    @objc func editPointSegue(sender: UIButton) {
        self.performSegue(withIdentifier: "editCollectionPoint", sender: self)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        var color: UIColor = .red
        
        if annotation.title == "New Collection Point" {
            color = .blue
        }
        
        //        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "draggablePoint") {
        //            return annotationView
        //        } else {
        return CollectionPointDraggableAnnotationView(annotation: annotation as! CollectionPointPointAnnotation, reuseIdentifier: "draggablePoint", size: 20, color: color)
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            controller.detailItem = self.newAnnotation.collectionPoint
        }
        
        if segue.identifier == "editCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            controller.detailItem = self.selectedCollectionPoint
        }
    }
}
