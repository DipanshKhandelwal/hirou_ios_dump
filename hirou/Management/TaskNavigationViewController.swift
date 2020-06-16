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

import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class TaskCollectionPointCollectionCell : UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    var position: Int?
}

extension TaskNavigationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 256, height: 128)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCollectionPointCollectionCell", for: indexPath) as! TaskCollectionPointCollectionCell
        cell.title?.text = "hello" + String(indexPath.row)
        cell.position = indexPath.row
        return cell
    }
    
}

class TaskNavigationViewController: UIViewController, MGLMapViewDelegate, NavigationViewControllerDelegate {
    var id: String = ""
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedTaskCollectionPoint: TaskCollectionPoint!
    var taskCollectionPoints = [TaskCollectionPoint]()
    var annotations = [MGLPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        // Do any additional setup after loading the view.
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
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            let navigationService = MapboxNavigationService(route: route, simulating: .never)
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            let navigationViewController = NavigationViewController(for: route, options: navigationOptions)
            navigationViewController.delegate = self
            
            self.present(navigationViewController, animated: true, completion: nil)
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
                
                collectionView.selectItem(at: IndexPath(row: currentIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                
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
