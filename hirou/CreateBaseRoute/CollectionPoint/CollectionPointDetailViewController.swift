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
    var newAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    var collectionPoints = [CollectionPoint]()
    var annotations = [MGLPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        configureView()
        
        self.id = UserDefaults.standard.string(forKey: "selectedRoute")!
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleNewPointTap(_:)))
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
                    let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )
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
            let annotation = MGLPointAnnotation()
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //            annotation.coordinate = CLLocationCoordinate2D(latitude: 35.03946, longitude: 135.72956)
            annotation.title = cp.name
            annotation.subtitle = "\(Double(round(annotation.coordinate.latitude*1000)/1000)), \(Double(round(annotation.coordinate.longitude*1000)/1000))"
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
        
        mapView.removeAnnotation(self.newAnnotation)
        self.newAnnotation = MGLPointAnnotation()
        
        self.newAnnotation.coordinate = location
        //            annotation.coordinate = CLLocationCoordinate2D(latitude: 35.03946, longitude: 135.72956)
        self.newAnnotation.title = "New Collection Point"
        self.newAnnotation.subtitle = "\(self.newAnnotation.coordinate.latitude), \(self.newAnnotation.coordinate.longitude)"
        mapView.addAnnotation(self.newAnnotation)
        mapView.selectAnnotation(self.newAnnotation, animated: true, completionHandler: nil)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        label.textAlignment = .right
        label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        label.text = "CP"
        return label
    }
    
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let addPoint = UIButton(type: .contactAdd)
        addPoint.addTarget(self, action: #selector(addPointSegue(sender:)), for: .touchDown)
        return addPoint
    }
    
    @objc func addPointSegue(sender: UIButton) {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "addCollectionPoint", sender: self)
        }
    }
    
    //    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    //        // Hide the callout view.
    //        mapView.deselectAnnotation(annotation, animated: false)
    //        // Show an alert containing the annotation's details
    //        //        let alert = UIAlertController(title: annotation.title!!, message: "A lovely (if touristy) place.", preferredStyle: .alert)
    //        //        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //        //        self.present(alert, animated: true, completion: nil)
    //    }
    
    
    
    
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
}




//import UIKit
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections
//import Mapbox
//
//
//class CollectionPointDetailViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate {
//
//    var mapView: NavigationMapView?
//    var currentRoute: Route? {
//        get {
//            return routes?.first
//        }
//        set {
//            guard let selected = newValue else { routes?.remove(at: 0); return }
//            guard let routes = routes else { self.routes = [selected]; return }
//            self.routes = [selected] + routes.filter { $0 != selected }
//        }
//    }
//    var routes: [Route]? {
//        didSet {
//            guard let routes = routes, let current = routes.first else { mapView?.removeRoutes(); return }
//            mapView?.showRoutes(routes)
//            mapView?.showWaypoints(current)
//        }
//    }
//    var startButton: UIButton?
//    var locationManager = CLLocationManager()
//
//    private typealias RouteRequestSuccess = (([Route]) -> Void)
//    private typealias RouteRequestFailure = ((NSError) -> Void)
//
//    //MARK: - Lifecycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//
//        mapView = NavigationMapView(frame: view.bounds)
//        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        mapView?.userTrackingMode = .follow
//        mapView?.delegate = self
//        mapView?.navigationMapViewDelegate = self
//
////        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
////        mapView?.addGestureRecognizer(gesture)
//
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        mapView?.addGestureRecognizer(gesture)
//
//
//        view.addSubview(mapView!)
//
//        startButton = UIButton()
//        startButton?.setTitle("Start Navigation", for: .normal)
//        startButton?.translatesAutoresizingMaskIntoConstraints = false
//        startButton?.backgroundColor = .blue
//        startButton?.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//        startButton?.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
//        startButton?.isHidden = true
//        view.addSubview(startButton!)
//        startButton?.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
//        startButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        view.setNeedsLayout()
//    }
//
//    //overriding layout lifecycle callback so we can style the start button
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        startButton?.layer.cornerRadius = startButton!.bounds.midY
//        startButton?.clipsToBounds = true
//        startButton?.setNeedsDisplay()
//    }
//
//
//    @objc func tappedButton(sender: UIButton) {
//        guard let route = currentRoute else { return }
//        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
//        let navigationService = MapboxNavigationService(route: route, simulating: .always)
//        let navigationOptions = NavigationOptions(navigationService: navigationService)
//        let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
//        navigationViewController.delegate = self
//
//        present(navigationViewController, animated: true, completion: nil)
//    }
//
//     @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .ended else { return }
//
//        let spot = gesture.location(in: mapView)
//        guard let location = mapView?.convert(spot, toCoordinateFrom: mapView) else { return }
//
//        requestRoute(destination: location)
//    }
//
//    func requestRoute(destination: CLLocationCoordinate2D) {
//        guard let userLocation = mapView?.userLocation!.location else { return }
//        let userWaypoint = Waypoint(location: userLocation, heading: mapView?.userLocation?.heading, name: "user")
//        let destinationWaypoint = Waypoint(coordinate: destination)
//
//        let options = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
//
//        Directions.shared.calculate(options) { (waypoints, routes, error) in
//            guard let routes = routes else { return }
//            self.routes = routes
//            self.startButton?.isHidden = false
//            self.mapView?.showRoutes(routes)
//            self.mapView?.showWaypoints(self.currentRoute!)
//        }
//    }
//
//    // Delegate method called when the user selects a route
//    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
//        self.currentRoute = route
//    }
//}

