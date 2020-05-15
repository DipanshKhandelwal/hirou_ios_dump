//
//  RouteDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//
//
//import UIKit
//import Mapbox
//import Alamofire

//class CollectionPointDetailViewController: UIViewController, MGLMapViewDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        configureView()
        
        self.id = UserDefaults.standard.string(forKey: "selectedRoute")!
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleNewPointTap(_:)))
        mapView?.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let id = self.id
        let url = "http://127.0.0.1:8000/api/base_route/"+String(id)+"/"
        AF.request(url, method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.collectionPoints = []
                self.annotations = []
                let cps = (value as AnyObject)["collection_point"]
                
                for collectionPoint in cps as! [Any] {
                    let id = ((collectionPoint as AnyObject)["id"] as! Int)
                    let name = ((collectionPoint as AnyObject)["name"] as! String)
                    let address = ((collectionPoint as AnyObject)["address"] as! String)
                    let route = ((collectionPoint as AnyObject)["route"] as! Int)
                    let locationCoordinates = ((collectionPoint as AnyObject)["location"] as! String).split{$0 == ","}.map(String.init)
                    let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )!
                    let sequence = ((collectionPoint as AnyObject)["sequence"] as! Int)
                    let collectionPointObj = CollectionPoint(id: id, name: name, address: address, route: route, location: location, sequence: sequence, image: "")
                    self.collectionPoints.append(collectionPointObj!)
                }
                self.addPointsTopMap()
                
            case .failure(let error):
                print(error)
            }
        }
        
        super.viewWillAppear(animated)
    }
    
    func addPointsTopMap() {
        for cp in self.collectionPoints {
            let annotation = CollectionPointPointAnnotation(collectionPoint: cp)
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //            annotation.coordinate = CLLocationCoordinate2D(latitude: 35.03946, longitude: 135.72956)
            annotation.title = cp.name
//            annotation.subtitle = "\(Double(annotation.coordinate.latitude)), \(Double(annotation.coordinate.longitude))"
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        
        self.handleAutomaticZoom()
        // Center the map on the annotation.
        //        mapView.setCenter(annotations[0].coordinate, zoomLevel: 14, animated: false)
        
        // Pop-up the callout view.
        //        mapView.selectAnnotation(annotations[0], animated: true, completionHandler: nil)
    }
    
    func handleAutomaticZoom() {
        let annotations = self.annotations
        
        if annotations.count > 0 {
            
            let firstCoordinate = annotations[0].coordinate
            
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
        let seq = self.collectionPoints.count
        
        self.newAnnotation = CollectionPointPointAnnotation(collectionPoint: CollectionPoint(id: -1, name: "", address: "", route: Int(self.id) ?? -1, location: loc, sequence: seq, image: "")!)
        
        self.newAnnotation.coordinate = location
        self.newAnnotation.title = "New Collection Point"
        mapView.addAnnotation(self.newAnnotation)
        mapView.selectAnnotation(self.newAnnotation, animated: true, completionHandler: nil)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
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
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "addCollectionPoint", sender: self)
        }
    }
    
    @objc func editPointSegue(sender: UIButton) {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "editCollectionPoint", sender: self)
        }
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
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            let ss = (detail as! CollectionPoint).id
            print("self.id", ss)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            let lat = self.newAnnotation.coordinate.latitude
            let long = self.newAnnotation.coordinate.longitude
            let loc = Location(latitude: String(lat), longitude: String(long))!
            let seq = self.collectionPoints.count
            let cp = CollectionPoint(id: -1, name: "", address: "", route: Int(self.id) ?? -1, location: loc, sequence: seq, image: "")
            controller.detailItem = cp
        }
        
        if segue.identifier == "editCollectionPoint" {
            let controller = (segue.destination as! CollectionPointFormViewController)
            controller.detailItem = self.selectedCollectionPoint
        }
    }
}
