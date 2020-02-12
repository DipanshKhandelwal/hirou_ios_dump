//
//  LoginViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

//import Mapbox
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections

class LoginViewController: UIViewController {
    
    //    var mapView: NavigationMapView!
    //    var directionsRoute: Route?
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //        // Do any additional setup after loading the view.
        //
        //        mapView = NavigationMapView(frame: view.bounds)
        //
        //        view.addSubview(mapView)
        //
        //        // Set the map view's delegate
        //        mapView.delegate = self
        //
        //        // Allow the map to display the user's location
        //        mapView.showsUserLocation = true
        //        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        //
        //        // Add a gesture recognizer to the map view
        //        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        //        mapView.addGestureRecognizer(longPress)
    }
    
    
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        //        print(username.text!)
        //        print(password.text!)
        //        AF.request("http://127.0.0.1:8000/rest-auth/login/", method: .post)
        
        
        let user = username.text!
        let pass = password.text!
        
        let parameters = ["username": user, "password": pass]
        
        AF.request("http://127.0.0.1:8000/rest-auth/login/", method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .failure(let error):
                // Do whatever here
                return
                
            case .success(let data):
                // First make sure you got back a dictionary if that's what you expect
                guard let json = data as? [String : AnyObject] else {
                    //                    NSAlert.okWithMessage("Failed to get expected response from webserver.")
                    return
                }
                
                print("json", json)
                
                // Then make sure you get the actual key/value types you expect
//                guard var points = json["points"] as? Double,
//                    let additions = json["additions"] as? [[String : AnyObject]],
//                    let used = json["used"] as? [[String : AnyObject]] else {
//                        //                        NSAlert.okWithMessage("Failed to get data from webserver")
//                        return
//                }
                
            }
            
        }
        
    }
    
    
    
    
    
    //    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
    //        guard sender.state == .began else { return }
    //
    //        // Converts point where user did a long press to map coordinates
    //        let point = sender.location(in: mapView)
    //        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
    //
    //        // Create a basic point annotation and add it to the map
    //        let annotation = MGLPointAnnotation()
    //        annotation.coordinate = coordinate
    //        annotation.title = "Start navigation"
    //        mapView.addAnnotation(annotation)
    //
    //        // Calculate the route from the user's location to the set destination
    //        calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
    //            if error != nil {
    //                print("Error calculating route")
    //            }
    //        }
    //    }
    
    // Calculate route to be used for navigation
    //    func calculateRoute(from origin: CLLocationCoordinate2D,
    //                        to destination: CLLocationCoordinate2D,
    //                        completion: @escaping (Route?, Error?) -> ()) {
    //
    //        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
    //        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
    ////        let middlePoint = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
    //        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
    //
    //
    //        // Specify that the route is intended for automobiles avoiding traffic
    //        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
    //
    //        // Generate the route object and draw it on the map
    //        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
    //            self.directionsRoute = routes?.first
    //            // Draw the route on the map after creating it
    //            self.drawRoute(route: self.directionsRoute!)
    //        }
    //    }
    
    //    func drawRoute(route: Route) {
    //        guard route.coordinateCount > 0 else { return }
    //        // Convert the route’s coordinates into a polyline
    //        var routeCoordinates = route.coordinates!
    //        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
    //
    //        // If there's already a route line on the map, reset its shape to the new route
    //        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
    //            source.shape = polyline
    //        } else {
    //            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
    //
    //            // Customize the route line color and width
    //            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
    //            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
    //            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
    //
    //            // Add the source and style layer of the route line to the map
    //            mapView.style?.addSource(source)
    //            mapView.style?.addLayer(lineStyle)
    //        }
    //    }
    
    //    // Implement the delegate method that allows annotations to show callouts when tapped
    //    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    //        return true
    //    }
    //
    //    // Present the navigation view controller when the callout is selected
    //    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
    //        let navigationViewController = NavigationViewController(for: directionsRoute!)
    //        navigationViewController.modalPresentationStyle = .fullScreen
    //        self.present(navigationViewController, animated: true, completion: nil)
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
