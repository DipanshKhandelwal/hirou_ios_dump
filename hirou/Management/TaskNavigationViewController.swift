//
//  TaskNavigationViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 01/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import FSPagerView
import CoreLocation

//class TaskNavigationViewController: UIViewController, MGLMapViewDelegate, NavigationViewControllerDelegate {
class TaskNavigationViewController: UIViewController, GMSMapViewDelegate {
    var id: String = ""
    
    @IBOutlet weak var usersCountText: UILabel!
//    @IBOutlet weak var mapView: NavigationMapView!
    @IBOutlet weak var taskCollectionContainer: UIView!
    @IBOutlet weak var taskCollectionTableView: TaskCollectionPointTable!
    @IBOutlet weak var taskCollectionPointHeightCst: NSLayoutConstraint!
    @IBOutlet weak var taskCollectionHeightCst: NSLayoutConstraint!
    @IBOutlet weak var tcpBottomCstWithTC: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var clvTask: UICollectionView!{
        didSet {
            self.clvTask.delegate = self
            self.clvTask.dataSource = self
            self.clvTask.register(UINib(nibName: "TaskCollectionPointPageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "taskCollectionPointPagerCell")
        }
    }
    var taskCollections = [TaskCollection]()
    @IBOutlet weak var tbvTaskCollection: UITableView! {
        didSet {
            tbvTaskCollection.dataSource = self
            tbvTaskCollection.delegate = self
        }
    }
    @IBOutlet weak var lineTaskCollection: UIView!
    @IBOutlet weak var lineTaskCollectionsPoint: UIView!
    @IBOutlet weak var containerHideTask: RoundedView!
    @IBOutlet weak var containerHideLocation: RoundedView!
    @IBOutlet weak var btnReport: UIButton!
    
    @IBOutlet weak var zoomOutButton: UIButton! {
        didSet {
//            zoomOutButton.setBackgroundImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left.circle"), for: .normal)
            zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchDown)
        }
    }
    
    @IBOutlet weak var zoomInButton: UIButton! {
        didSet {
//            zoomInButton.setBackgroundImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle"), for: .normal)
            zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchDown)
        }
    }
    
    var selectedTaskCollectionPoint: TaskCollectionPoint! {
        didSet {
            print("setup map config")
            configureView()
            guard let currentLocation = currentLocation, let selectedLocation = mapView.selectedMarker?.position  else { return }
            fetchRoute(from: currentLocation, to: selectedLocation)
        }
    }
    var taskCollectionPoints = [TaskCollectionPoint]()
    
//    var annotations = [TaskCollectionPointPointAnnotation]()
    var markers = [TaskCollectionPointMarker]()
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            guard let currentLocation = currentLocation, let selectedLocation = mapView.selectedMarker?.position  else { return }
            fetchRoute(from: currentLocation, to: selectedLocation)
        }
    }
    var userLocationMarkers = [UserLocationMarker]()
    var route:TaskRoute?
    var hideCompleted: Bool = false
    var hideMarker: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerHideLocation?.backgroundColor = self.hideMarker ? .white : UIColor(0x56cb87)
                self.containerHideLocation.subviews.forEach({
                    if let imageView = $0 as? UIImageView {
                        imageView.image = self.hideMarker ? UIImage(named: "ic_location_green") : UIImage(named: "ic_location_white")
                    } else if let label = $0 as? UILabel {
                        label.textColor = self.hideMarker ? UIColor(0x120101) : .white
                    }
                })
            })
            if hideMarker {
                markers.forEach({
                    $0.map = nil
                })
            } else {
                markers.forEach({
                    $0.map = mapView
                })
            }
        }
    }
    var isHideTask: Bool = false
    var isUserTrackingMode: Bool = true
    
    let minHeightTC: CGFloat = 208 + bottomSafeArea
    var maxHeightTC: CGFloat {
        // maxHeight = heightScreenAvailable - (topViewTable + spacingTableWBottomSheet + minHeightTable)
        return heightScreenAvailable - (20 + 24 + 32)
    }
    static private var bottomSafeArea: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    private var heightScreenAvailable: CGFloat {
        return view.bounds.height
    }
    
    private(set) var isTaskCollectionsHidden: Bool = true
        
    let notificationCenter = NotificationCenter.default
    
    let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.USER_ID)
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleHideTask(isHideTask: false, showAnimtionTask: true)
        hideMarker = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        
        let completedHiddenSwitch = UISwitch(frame: .zero)
        completedHiddenSwitch.isOn = false
        completedHiddenSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        let switch_display = UIBarButtonItem(customView: completedHiddenSwitch)
        navigationItem.setRightBarButtonItems([switch_display], animated: true)
        
        self.id = UserDefaults.standard.string(forKey: "selectedTaskRoute")!
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsVListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdateFromVList(_:)), name: .TaskCollectionPointsHListUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointSelectFromVList(_:)), name: .TaskCollectionPointsHListSelect, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideCompletedTriggered(_:)), name: .TaskCollectionPointsHideCompleted, object: nil)
        notificationCenter.addObserver(self, selector: #selector(collectionPointUpdate(_:)), name: .TaskCollectionPointsUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(locationsUpdated(_:)), name: .TaskCollectionPointsUserLocationsUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(presentUserLocationUpdated(_:)), name: .TaskCollectionPointsPresentUserLocationUpdate, object: nil)
        lineTaskCollection.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(animationHeightTaskCollections(_:))))
        lineTaskCollectionsPoint.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(animationHeightTaskCollections(_:))))
        self.getPoints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskCollectionTableView.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        taskCollectionTableView.viewDidDisappear()
        AppUtility.lockOrientation(.all)
    }

    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
    }
    
    @IBOutlet weak var trackUserButton: UIButton! {
        didSet {
            trackUserButton.setBackgroundImage(UIImage(systemName: "location.fill"), for: .normal)
            isUserTrackingMode = true
            trackUserButton.addTarget(self, action: #selector(userTrackingSwitchToggled), for: .touchDown)
        }
    }
    
    @objc
    func userTrackingSwitchToggled() {
        if !isUserTrackingMode {
            isUserTrackingMode = true
            trackUserButton.setBackgroundImage(UIImage(systemName: "location.fill"), for: .normal)
        }
        else{
            isUserTrackingMode = false
            trackUserButton.setBackgroundImage(UIImage(systemName: "location"), for: .normal)
        }
    }
    
    @IBAction func reportAdminAction(_ sender: Any) {
        let viewController = ReportAdminFormPopup()
        viewController.currentTaskCollectionPoint = self.selectedTaskCollectionPoint
        viewController.selectedCollectionPoint = self.selectedTaskCollectionPoint?.id
        let popup = PopupViewController(contentController: viewController, position: .center(nil), popupWidth: UIScreen.main.bounds.width / 2.7, popupHeight: UIScreen.main.bounds.height / 1.5)
        popup.canTapOutsideToDismiss = false
        present(popup, animated: true, completion: nil)
        
    }
    
    @IBAction func toggleHideMarker(_ sender: UIButton) {
        hideMarker = !hideMarker
    }
    
    @IBAction func toggleHideTask(_ sender: Any) {
        toggleHideTask(isHideTask: !isHideTask, showAnimtionTask: true)
    }
    
    private func toggleHideTask(isHideTask: Bool, showAnimtionTask: Bool = false) {
        self.isHideTask = isHideTask
        self.clvTask.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.containerHideTask?.backgroundColor = isHideTask ? UIColor(0x007aff) : .white
            self.containerHideTask.subviews.forEach({
                if let imageView = $0 as? UIImageView {
                    imageView.image = isHideTask ? UIImage(named: "ic_eyes_white") : UIImage(named: "ic_eyes")
                } else if let label = $0 as? UILabel {
                    label.textColor = isHideTask ? .white : UIColor(0x120101)
                }
            })
        }, completion: { _ in
            self.clvTask.isHidden = isHideTask
        })
        guard showAnimtionTask else { return }
        if isHideTask {
            tcpBottomCstWithTC.priority = UILayoutPriority(999)
            taskCollectionPointHeightCst.priority = UILayoutPriority(1000)
            UIView.animate(withDuration: 0.3, animations: {
                self.taskCollectionHeightCst.constant = 48 + TaskNavigationViewController.bottomSafeArea
                self.taskCollectionPointHeightCst.constant = 32
                self.view.layoutIfNeeded()
            })
        } else {
            tcpBottomCstWithTC.priority = UILayoutPriority(1000)
            taskCollectionPointHeightCst.priority = UILayoutPriority(999)
            animationHideTaskCollections()
        }
    }
    
    @IBAction func toggleMapType(_ sender: Any) {
        if mapView.mapType == .satellite {
            mapView.mapType = .normal
        } else {
            mapView.mapType = .satellite
        }
    }
    
    func animationShowTaskCollections() {
        UIView.animate(withDuration: 0.3, animations: {
            self.taskCollectionHeightCst.constant = self.maxHeightTC
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.btnReport.isHidden = false
        })
        isTaskCollectionsHidden = false
        toggleHideTask(isHideTask: false)
    }
    
    func animationHideTaskCollections() {
        UIView.animate(withDuration: 0.3, animations: {
            self.taskCollectionHeightCst.constant = self.minHeightTC
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.btnReport.isHidden = true
        })
        isTaskCollectionsHidden = true
        toggleHideTask(isHideTask: false)
    }
    
    @objc func animationHeightTaskCollections(_ sender: UIPanGestureRecognizer) {
        tcpBottomCstWithTC.priority = UILayoutPriority(1000)
        taskCollectionPointHeightCst.priority = UILayoutPriority(999)
        self.btnReport.isHidden = false
        self.clvTask.isHidden = false
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self.view)
            var heightTC = taskCollectionHeightCst.constant - translation.y
            if heightTC <= minHeightTC {
                heightTC = minHeightTC
            } else if heightTC >= maxHeightTC {
                heightTC = maxHeightTC
            }
            self.taskCollectionHeightCst.constant = heightTC
        case .ended:
            let translation = sender.translation(in: self.view)
            let heightTC = taskCollectionHeightCst.constant - translation.y
            if heightTC <= maxHeightTC / 2 {
                animationHideTaskCollections()
            } else {
                animationShowTaskCollections()
            }
        default:
            break
        }
    }
    
    func getTaskCollectionPoints () -> [TaskCollectionPoint] {
        if(hideCompleted) {
            return self.taskCollectionPoints.filter { !$0.getCompleteStatus() }
        }
        return self.taskCollectionPoints
    }
    
    @objc
    func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            self.notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: true)
        }
        else{
            notificationCenter.post(name: .TaskCollectionPointsHideCompleted, object: false)
        }
    }
    
    @objc
    func hideCompletedTriggered(_ notification: Notification) {
        let status = notification.object as! Bool
        hideCompletedFunc(hideCompleted: status)
    }
    
    
    func hideCompletedFunc(hideCompleted : Bool = false) {
        self.hideCompleted = hideCompleted
        DispatchQueue.main.async {
            self.clvTask.reloadData()
            self.addPointsTopMap()
        }
    }

    @objc
    func collectionPointUpdateFromVList(_ notification: Notification) {
        let tcs = notification.object as! [TaskCollection]
        DispatchQueue.main.async {
            for tc in tcs {
                for tcp in self.taskCollectionPoints {
                    if let index = tcp.taskCollections.firstIndex(where: { $0.id == tc.id }) {
                        tcp.taskCollections[index] = tc
                    }
                }
            }
            self.addPointsTopMap()
            self.clvTask.reloadItems(at: self.clvTask.visibleCells.compactMap({ self.clvTask.indexPath(for: $0) }))
        }
        
    }
    
    @objc
    func collectionPointUpdate(_ notification: Notification) {
        let tcPoints = notification.object as! [TaskCollectionPoint]
        self.taskCollectionPoints = tcPoints
        DispatchQueue.main.async {
            self.addPointsTopMap()
            self.clvTask.reloadData()
        }
    }
    
    @objc
    func collectionPointSelectFromVList(_ notification: Notification) {
        let tc = notification.object as! TaskCollectionPoint
        let data = getTaskCollectionPoints()
        
        for num in 0...data.count-1 {
            if tc.id == data[num].id {
                focusPoint(index: num)
                clvTask.scrollToItem(at: IndexPath(row: num, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func focusPoint(index: Int) {
        mapView.selectedMarker = self.markers[index]
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: Double(self.getTaskCollectionPoints()[index].location.latitude)!, longitude: Double(self.getTaskCollectionPoints()	[index].location.longitude)!))
        mapView.animate(toZoom: 18)
        clvTask.reloadData()
        
//        if let numberOfItems = clvTask.numberOfItems(inSection: 0), numberOfItems > 0 {
//            if(numberOfItems > index) {
//                collectionView.scrollToItem(at: index, animated: true)
//            }
//        }
    }
    
    func editPointSegue() {
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
            controller.route = self.route
        }
    }

}
