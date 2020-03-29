//
//  RouteNavigationViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 27/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Foundation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Alamofire

class RouteNavigationViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate {

    var collectionPoints = [CollectionPoint]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        let url = "http://127.0.0.1:8000/api/base_route/1/"

        AF.request(url, method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                // completion(try? SomeRequest(protobuf: value))
                //                print("response", value)
                // self.vehicles = value as! [Any]
                self.collectionPoints = []
                let cps = (value as AnyObject)["collection_point"]

                for collectionPoint in cps as! [Any] {
                    let id = ((collectionPoint as AnyObject)["id"] as! Int)
                    let name = ((collectionPoint as AnyObject)["name"] as! String)
                    let address = ((collectionPoint as AnyObject)["address"] as! String)
                    let route = ((collectionPoint as AnyObject)["route"] as! Int)

                    let locationCoordinates = ((collectionPoint as AnyObject)["location"] as! String).split{$0 == ","}.map(String.init)
                    let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )

                    let sequence = ((collectionPoint as AnyObject)["sequence"] as! Int)
                    // let image = ((collectionPoint as AnyObject)["image"] as! String?)

                    let collectionPointObj = CollectionPoint(id: id, name: name, address: address, route: route, location: location, sequence: sequence, image: "")

                    self.collectionPoints.append(collectionPointObj!)
                }
                self.startNavigation()

            case .failure(let error):
                print(error)

            }
        }

        super.viewWillAppear(animated)
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


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
//
//import UIKit
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections
//import Mapbox
//
//
//class RouteNavigationViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, NavigationMapViewDelegate, NavigationViewControllerDelegate {
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
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        mapView?.addGestureRecognizer(gesture)
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
//
//    }
//
//
//    @objc func tappedButton(sender: UIButton) {
//        guard let route = currentRoute else { return }
//        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
//        let navigationService = MapboxNavigationService(route: route, simulating: true ? .always : .onPoorGPS)
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
