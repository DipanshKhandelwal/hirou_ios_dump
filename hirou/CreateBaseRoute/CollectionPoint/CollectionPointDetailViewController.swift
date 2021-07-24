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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithCourse
        mapView.showsUserHeadingIndicator = true
//        mapView.zoomLevel = 22

        self.id = UserDefaults.standard.string(forKey: "selectedRoute")!
        
        self.gestures = self.mapView.gestureRecognizers ?? []
        toggleGestures(disable: true)
        
        self.addNewPointGesture()
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .CollectionPointsTableSelect, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointReorderFromVList(_:)), name: .CollectionPointsTableReorder, object: nil)
    }
    
    @objc
    func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            toggleGestures(disable: true)
            self.addNewPointGesture()
            mapView.userTrackingMode = .followWithCourse
            mapView.showsUserHeadingIndicator = true
        }
        else{
            toggleGestures(disable: false)
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
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                let newCollectionPoints = route.collectionPoints
                self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsToMap()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsToMap() {
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
        Sound.playInteractionSound()
        
        if annotation.title == "New Collection Point" {
            return
        }
        
        if(annotation is CollectionPointPointAnnotation) {
            let ann = annotation as! CollectionPointPointAnnotation
            let annCpId = ann.collectionPoint.id
            for (index, cp) in self.collectionPoints.enumerated() {
                if annCpId == cp.id {
                    self.selectedCollectionPoint = self.collectionPoints[index];
                    self.notificationCenter.post(name: .CollectionPointsMapSelect, object: self.collectionPoints[index])
                    break
                }
            }
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
            if(annotation is CollectionPointPointAnnotation) {
                let ann = annotation as! CollectionPointPointAnnotation
                let annCpId = ann.collectionPoint.id
                for (currentIndex, cp) in self.collectionPoints.enumerated() {
                    if annCpId == cp.id {
                        self.selectedCollectionPoint = self.collectionPoints[currentIndex];
                        break
                    }
                }
                let editPoint = UIButton(type: .detailDisclosure)
                editPoint.addTarget(self, action: #selector(editPointSegue(sender:)), for: .touchDown)
                return editPoint
            }
        }
        return nil
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
