//
//  CollectionPointMasterViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class CollectionPointTableViewCell : UITableViewCell {
    @IBOutlet weak var collectionPointIndexLabel: UILabel!
    @IBOutlet weak var collectionPointNameLabel: UILabel!
    @IBOutlet weak var collectionPointMemoLabel: UILabel!
    @IBOutlet weak var collectionPointImage: UIImageView!
}

class CollectionPointMasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    var detailViewController: CollectionPointDetailViewController? = nil
    var collectionPoints = [CollectionPoint]()
    
    let baseRouteId = UserDefaults.standard.string(forKey: "selectedRoute")!
    
    private let notificationCenter = NotificationCenter.default
    
    var socketConnection: WebSocketConnector?
    
    var locationManager: CLLocationManager?
    var presentLocation: CLLocation?
    var timer: Timer?

    private func setupConnection(){
        let userToken = UserDefaults.standard.string(forKey: UserDefaultsConstants.AUTH_TOKEN)
        let queryItems = [URLQueryItem(name: "token", value: userToken)]
        let socketBaseUrl = Environment.SERVER_SOCKET_URL + "subscribe/base-route/" + baseRouteId + "/"
        var urlComponent = URLComponents(string: socketBaseUrl)!
        urlComponent.queryItems = queryItems
        let finalUrl = urlComponent.url!
        socketConnection = WebSocketConnector(withSocketURL: finalUrl)

        socketConnection?.establishConnection()
        
        socketConnection?.didReceiveError = { error in
            //Handle error here
        }
        
        socketConnection?.didOpenConnection = {
            // Connection opened
        }
        
        socketConnection?.didCloseConnection = {
            // Connection closed
        }
        
        socketConnection?.didReceiveData = { data in
            // Get your data here
        }
        
        socketConnection?.didReceiveMessage = {message in
            print("message", message)
            let dict = convertToDictionary(text: message)
            if let event = dict?[SocketKeys.EVENT] as?String, let sub_event = dict?[SocketKeys.SUB_EVENT] as?String {
                if event == SocketEventTypes.BASE_ROUTE {
                    switch sub_event {
                        case SocketSubEventTypes.REORDER: do {
                            let baseRouteData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                            let route = try! JSONDecoder().decode(BaseRoute.self, from: baseRouteData!)
                            if route.id == Int(self.baseRouteId) {
                                self.updateFromBaseRoute(route: route, notify: true)
                            }
                            break;
                        }

                            default:
                                break;
                        }
                }
                
                else if event == SocketEventTypes.COLLECTION_POINT {
                    switch sub_event {
                        case SocketSubEventTypes.CREATE, SocketSubEventTypes.UPDATE, SocketSubEventTypes.DELETE: do {
                            let baseRouteData = jsonToNSData(json: dict?[SocketKeys.DATA] as Any)
                            let route = try! JSONDecoder().decode(BaseRoute.self, from: baseRouteData!)
                            if route.id == Int(self.baseRouteId) {
                                self.updateFromBaseRoute(route: route, notify: true)
                            }
                            break;
                        }
                        
                        default:
                            break;
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //        navigationItem.leftBarButtonItem = editButtonItem
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CollectionPointDetailViewController
        }
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromMap(_:)), name: .CollectionPointsMapSelect, object: nil)

        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.setLeftBarButtonItems([backButton], animated: true)

        setupConnection()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in self.updateLocation() })
    }
    
    @objc
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            presentLocation = location
        }
    }
    
    func updateLocation() {
        if presentLocation == nil {
            print("Present Location not found :: Location not updated")
            return
        }
        
        let latitude = (presentLocation?.coordinate.latitude)!
        let longitude = (presentLocation?.coordinate.longitude)!
        
        let location2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.notificationCenter.post(name: .CollectionPointsPresentUserLocationUpdate, object: location2D)
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        socketConnection?.disconnect()
        socketConnection = nil
    }
    
    @objc
    func collectionPointUpdateFromMap(_ notification: Notification) {
        let cp = notification.object as! CollectionPoint
        if self.collectionPoints.count == 0 {
            return
        }
        if(self.collectionPoints.count > 0) {
            for num in 0...self.collectionPoints.count-1 {
                if self.collectionPoints[num].id == cp.id {
                    self.tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: .middle)
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        fetchCollectionPoints()
    }
    
    func updateFromBaseRoute(route: BaseRoute, notify: Bool = false) {
        let newCollectionPoints = route.collectionPoints
        self.collectionPoints = newCollectionPoints.sorted() { $0.sequence < $1.sequence }
        if notify {
            self.notificationCenter.post(name: .CollectionPointsTableReorder, object: self.collectionPoints)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchCollectionPoints(notify: Bool = false){
        let id = self.baseRouteId
        let url = Environment.SERVER_URL + "api/base_route/"+String(id)+"/"
        let headers = APIHeaders.getHeaders()
        AF.request(url, method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let route = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                self.updateFromBaseRoute(route: route, notify: notify)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.collectionPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionPointCell", for: indexPath) as! CollectionPointTableViewCell
        let collectionPoint = collectionPoints[indexPath.row]
        cell.collectionPointNameLabel!.text = collectionPoint.name
        cell.collectionPointMemoLabel!.text = collectionPoint.memo
        cell.collectionPointIndexLabel!.text = String(collectionPoint.sequence)
        
        if let image = cell.collectionPointImage {
            image.image = UIImage(named: "placeholder")
            
            if collectionPoint.image != nil {
                DispatchQueue.global().async { [] in
                    let url = NSURL(string: collectionPoint.image!)! as URL
                    if let imageData: NSData = NSData(contentsOf: url) {
                        DispatchQueue.main.async {
                            image.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Sound.playInteractionSound()
        
        self.notificationCenter.post(name: .CollectionPointsTableSelect, object: self.collectionPoints[indexPath.row])
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let fromIndex = fromIndexPath[1]
        let toIndex = to[1]
        
        if fromIndex == toIndex { return }
        
        let updateAlert = UIAlertController(title: "Update sequence ?", message: "Are you sure you want to update the sequence ?", preferredStyle: .alert)
        
        updateAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Update sequence cancelled by the user.")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        
        updateAlert.addAction(UIAlertAction(title: "Yes. Update", style: .default, handler: { (action: UIAlertAction!) in
            let cp: CollectionPoint = self.collectionPoints[fromIndex]
            if(fromIndex < toIndex) {
                (fromIndex...toIndex-1).forEach { index in
                    self.collectionPoints[index] = self.collectionPoints[index+1]
                }
            }
            else {
                (toIndex+1...fromIndex).reversed().forEach { index in
                    self.collectionPoints[index] = self.collectionPoints[index-1]
                }
            }
            self.collectionPoints[toIndex] = cp
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.updateList()
        }))
        self.present(updateAlert, animated: true, completion: nil)
    }
    
    func updateList(){
        let baseRouteId = self.baseRouteId
        var array = [String]()
        for element in self.collectionPoints { array.append(String(element.id)) }
        let parameters: [String: [String]] = [
            "points": array
        ]
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/base_route/"+String(baseRouteId)+"/reorder_points/", method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response {
                response in
                switch response.result {
                case .success(let value):
                    let baseRoute = try! JSONDecoder().decode(BaseRoute.self, from: value!)
                    self.updateFromBaseRoute(route: baseRoute, notify: true)
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
}
