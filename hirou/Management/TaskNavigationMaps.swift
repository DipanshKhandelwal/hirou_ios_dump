//
//  TaskNavigationMaps.swift
//  hirou
//
//  Created by ThuNQ on 5/20/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire
import FSPagerView
import CoreLocation

extension TaskNavigationViewController {
    
    @objc func zoomIn() {
        let zoom = self.mapView.camera.zoom
        if(zoom + 1 <= self.mapView.maxZoom) {
            self.mapView.animate(toZoom: zoom + 1)
        }
    }
    
    @objc func zoomOut() {
        let zoom = self.mapView.camera.zoom
        if(zoom - 1 >= self.mapView.minZoom) {
            self.mapView.animate(toZoom: zoom - 1)
        }
    }
    
    @objc func presentUserLocationUpdated(_ notification: Notification) {
        let newUserLocation = notification.object as! CLLocationCoordinate2D
        currentLocation = newUserLocation
        if(isUserTrackingMode) {
            DispatchQueue.main.async {
                self.mapView.animate(toLocation: newUserLocation)
            }
        }
    }
    @objc func locationsUpdated(_ notification: Notification) {
        let newUserLocations = notification.object as! [UserLocation]
        DispatchQueue.main.async {
//            self.userLocationMarkers.forEach {userLocationMarker in
//                if String(userLocationMarker.userLocation.id) == self.userId { return }
//                userLocationMarker.map = nil
//            }
        }
        
        DispatchQueue.main.async {
            self.usersCountText?.text = String(newUserLocations.count)
        }

        DispatchQueue.main.async {
            newUserLocations.forEach { userLocation in
                if String(userLocation.id) == self.userId {
                    return
                }
                let lat = Double(userLocation.location.latitude)!
                let long = Double(userLocation.location.longitude)!
                let position =  CLLocationCoordinate2D(latitude: lat , longitude: long)
                if let marker = self.userLocationMarkers.first(where: { $0.userLocation.id == userLocation.id }) {
                    marker.position = position
                    marker.userLocation = userLocation
                    marker.map = self.mapView
                } else {
                    let markerObj = UserLocationMarker(userLocation: userLocation)
                    markerObj.position = position
                    
                    let markerIcon = UIImage(named: "truck")
                    markerObj.icon = markerIcon

                    markerObj.map = self.mapView
                    self.userLocationMarkers.append(markerObj)
                }
            }
        }
    }
    
    func getPoints() {
        let id = self.id
        let url = Environment.SERVER_URL + "api/task_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.route = try! JSONDecoder().decode(TaskRoute.self, from: value!)
                let newCollectionPoints = self.route!.taskCollectionPoints
                self.taskCollectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
                self.addPointsTopMap()
                
                DispatchQueue.main.async {
                    self.clvTask.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addPointsTopMap() {
        self.markers = []
        self.mapView.clear()
        
        for cp in getTaskCollectionPoints() {
            let markerObj = TaskCollectionPointMarker(taskCollectionPoint: cp)
            let lat = Double(cp.location.latitude)!
            let long = Double(cp.location.longitude)!
            let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            markerObj.position = position
            markerObj.title = cp.name
            markerObj.map = mapView
            markerObj.icon = UIImage(named: "ic_location_green")
            
            if(cp.getCompleteStatus()) {
                if(!self.hideCompleted) {
                    markerObj.icon = UIImage(named: "ic_location_gray")
                    self.markers.append(markerObj)
                }
                else {
                    markerObj.map = nil
                }
            }
            else {
            }
            self.markers.append(markerObj)
        }
        if mapView.selectedMarker == nil {
            mapView.selectedMarker = markers.first
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        Sound.playInteractionSound()

        if marker is TaskCollectionPointMarker {
            let ann = marker as! TaskCollectionPointMarker
            let annTcpId = ann.taskCollectionPoint.id

            for (index, cp) in self.taskCollectionPoints.enumerated() {
                if cp.id == annTcpId {
                    self.selectedTaskCollectionPoint = self.taskCollectionPoints[index];
                    
                    self.notificationCenter.post(name: .TaskCollectionPointsMapSelect, object: self.taskCollectionPoints[index])
                    
                    self.clvTask.reloadData()
                    let numberOfItems = clvTask.numberOfItems(inSection: 0)
                    if numberOfItems > 0 {
                        if(numberOfItems > index) {
                            clvTask.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                        }
                    }
                    
                    break
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        editPointSegue()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        print("setup map")
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W6", size: 14)!]
        var text = ""
        if let marker = marker as? TaskCollectionPointMarker {
            text = String(marker.taskCollectionPoint.sequence)
        } else if let marker = marker as? UserLocationMarker {
            text = marker.userLocation.name
        }
        let size = (text as NSString).size(withAttributes: fontAttributes)
        
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: max(size.width, 30) + 30, height:30));
        stack.axis = .horizontal
        stack.alignment = .center
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: max(size.width, 30), height: 30))
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.text = text
        stack.addArrangedSubview(label)
        
        if(marker is TaskCollectionPointMarker) {
            let ann = marker as! TaskCollectionPointMarker
            let annCpId = ann.taskCollectionPoint.id
            for (currentIndex, cp) in self.taskCollectionPoints.enumerated() {
                if annCpId == cp.id {
                    self.selectedTaskCollectionPoint = self.taskCollectionPoints[currentIndex];
                    break
                }
            }
            let editPoint = UIButton(type: .detailDisclosure)
            editPoint.frame.size = CGSize(width: 6, height: 6)
            stack.addArrangedSubview(editPoint)
        }
        
        return stack
    }
    
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(AppDelegate.gmsKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes.first as? [String: Any] else {
                return
            }

            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            //Call this method to draw path on map
            self.drawPath(from: polyLineString)
        })
        task.resume()
    }
    
    func drawPath(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor(0x3483ff)
        polyline.map = mapView // Google MapView
    }
}
