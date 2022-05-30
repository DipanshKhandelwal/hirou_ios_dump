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
//import MapboxNavigation
import UIKit

extension TaskNavigationViewController {
    private var mapRouted: [String: [String: String]]? {
        set {
            UserDefaults.standard.set(newValue, forKey: "mapRouted")
        }
        get {
            return UserDefaults.standard.value(forKey: "mapRouted") as? [String: [String: String]]
        }
    }
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
    
    @objc func toggleDirection() {
        isDirectionRoute = !isDirectionRoute
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
        let selectedMarker = mapView.selectedMarker as? TaskCollectionPointMarker
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
            } else {
                self.markers.append(markerObj)
            }
            
        }
        if let selectedMarker = selectedMarker,
           let marker = markers.first(where: { $0.taskCollectionPoint.id == selectedMarker.taskCollectionPoint.id }){
            mapView.selectedMarker = marker
        } else {
            mapView.selectedMarker = markers.first
        }
    }
    
    

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        Sound.playInteractionSound()

        if marker is TaskCollectionPointMarker {
            let ann = marker as! TaskCollectionPointMarker
            let annTcpId = ann.taskCollectionPoint.id
            if selectedTaskCollectionPoint.id == annTcpId {
                return true
            }
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
//        editPointSegue()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W6", size: 14)!]
        var text = ""
        if let marker = marker as? TaskCollectionPointMarker {
            text = String(marker.taskCollectionPoint.sequence)
        } else if let marker = marker as? UserLocationMarker {
            text = marker.userLocation.name
        }
        let size = (text as NSString).size(withAttributes: fontAttributes)
        
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: max(size.width, 30), height:30));
//        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: max(size.width, 30) + 30, height:30));
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
            if let tcp = taskCollectionPoints.first(where: { $0.id == annCpId }) {
                self.selectedTaskCollectionPoint = tcp
            }
            if let oldNextIndex = oldNextIndex,
               oldNextIndex < markers.count,
               let tcp = getTaskCollectionPoints().first(where: { $0.id == markers[oldNextIndex].taskCollectionPoint.id }) {
                if(tcp.getCompleteStatus()) {
                    markers[oldNextIndex].icon = UIImage(named: "ic_location_gray")
                } else {
                    markers[oldNextIndex].icon = UIImage(named: "ic_location_green")
                }
                self.oldNextIndex = nil
            }
            if let oldSelectedIndex = oldSelectedIndex,
               oldSelectedIndex < markers.count,
               let tcp = getTaskCollectionPoints().first(where: { $0.id == markers[oldSelectedIndex].taskCollectionPoint.id }) {
                if(tcp.getCompleteStatus()) {
                    markers[oldSelectedIndex].icon = UIImage(named: "ic_location_gray")
                } else {
                    markers[oldSelectedIndex].icon = UIImage(named: "ic_location_green")
                }
            }
            if let index = markers.firstIndex(of: ann),
               index + 1 < markers.count,
               let tcp = getTaskCollectionPoints().first(where: { $0.id == markers[index + 1].taskCollectionPoint.id }){
                if(tcp.getCompleteStatus()) {
                    markers[index + 1].icon = UIImage(named: "ic_next_point_gray")
                } else {
                    markers[index + 1].icon = UIImage(named: "ic_next_point_green")
                }
                oldNextIndex = index + 1
                oldSelectedIndex = index
            }
//            let editPoint = UIButton(type: .detailDisclosure)
//            editPoint.frame.size = CGSize(width: 6, height: 6)
//            stack.addArrangedSubview(editPoint)
        }
        marker.icon = UIImage(named: "ic_location_red")
        let view = UIView(frame: CGRect(x: 0, y: 0, width: max(size.width, 30), height:30))
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: max(size.width, 30) + 30, height:30))
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
    
    func clearRouting() {
        oldRoutingPoly?.map = nil
        oldRoutingPoly = nil
    }
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        guard isDirectionRoute else { return }
        if let oldDestination = oldDestinationRoute,
           oldDestination != destination {
            clearRouting()
        }
        oldOriginRoute = source
        oldDestinationRoute = destination
        if let destinationRouted = mapRouted?["\(destination.latitude),\(destination.longitude)"] {
            for item in destinationRouted {
                if let originRoutedLat = Double(item.key.components(separatedBy: ",").first ?? ""),
                   let originRoutedLong = Double(item.key.components(separatedBy: ",").last ?? "") {
                    let origin = CLLocation(latitude: source.latitude, longitude: source.longitude)
                    let originRouted = CLLocation(latitude: originRoutedLat, longitude: originRoutedLong)
                    if origin.distance(from: originRouted) < Constants.distanceUpdateRouting {
                        clearRouting()
                        drawPath(from: item.value)
                        return
                    }
                }
            }
        }
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
            if var mapRouted = self.mapRouted {
                if var destinationRouted = mapRouted[destination] {
                    destinationRouted["\(source.latitude),\(source.longitude)"] = polyLineString
                    mapRouted[destination] = destinationRouted
                    self.mapRouted = mapRouted
                } else {
                    mapRouted[destination] = ["\(source.latitude),\(source.longitude)": polyLineString]
                    self.mapRouted = mapRouted
                }
            } else {
                var mapRouted: [String: [String:String]] = [:]
                mapRouted[destination] = ["\(source.latitude),\(source.longitude)": polyLineString]
                self.mapRouted = mapRouted
            }
            //Call this method to draw path on map
            DispatchQueue.main.async {
                self.drawPath(from: polyLineString)
            }
        })
        task.resume()
    }
    
    func drawPath(from polyStr: String){
        clearRouting()
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor(0x3483ff)
        polyline.map = mapView // Google MapView
        oldRoutingPoly = polyline
    }
}

extension CLLocationCoordinate2D: Equatable {
    static public func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
