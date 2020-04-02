//
//  RouteDetailsViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 18/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire
import Mapbox
import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Alamofire

class RouteCollectionPointViewController: UIViewController, MGLMapViewDelegate {
    
    var collectionPoints = [CollectionPoint]()
    var annotations = [MGLPointAnnotation]()
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var navigate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.delegate = self
        configureView()
    }
    
    @IBAction func navigatePressed(_ sender: UIButton) {
        startNavigation()
    }
    
    func startNavigation() {
        var waypoints = [CLLocationCoordinate2D]()
        
        for cp in self.collectionPoints {
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            waypoints.append(CLLocationCoordinate2DMake(lat, long))
            if(waypoints.count >= 3) {break};
        }
        
        let options = NavigationRouteOptions(coordinates: waypoints)
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
            let navigationService = MapboxNavigationService(route: route, simulating: .always)
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
            navigationViewController.modalPresentationStyle = .fullScreen
            
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            print("id", (detail as! BaseRoute).id)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let detail = detailItem {
            let id = (detail as! BaseRoute).id
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
        let editButton = UIButton(type: .detailDisclosure)
        editButton.addTarget(self, action: #selector(editPointSegue(sender:)), for: .touchDown)
        return editButton
    }
    
    @objc func editPointSegue(sender: UIButton) {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "editCollectionPoint", sender: self)
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
}
