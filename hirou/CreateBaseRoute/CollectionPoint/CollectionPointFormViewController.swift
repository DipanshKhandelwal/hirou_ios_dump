//
//  CollectionPointFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 02/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire
import Mapbox

class CollectionPointFormViewController: UIViewController, MGLMapViewDelegate {

    
    @IBOutlet weak var cpNameLabel: UITextField!
    @IBOutlet weak var cpAddressLabel: UITextField!
    @IBOutlet weak var cpCoordinateslabel: UITextField!
    @IBOutlet var cpMapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cpMapView.delegate = self
        // Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = self.cpNameLabel {
                label.text = (detail as! CollectionPoint).name
            }
            
            if let label = self.cpAddressLabel {
                label.text = (detail as! CollectionPoint).address
            }
            
            if let label = self.cpCoordinateslabel {
                label.text = String((detail as! CollectionPoint).id)
            }
            
            if let map = self.cpMapView {
                let annotation = MGLPointAnnotation()
                let lat = Double((detail as! CollectionPoint).location.latitude)!
                let long = Double((detail as! CollectionPoint).location.longitude)!
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                //            annotation.coordinate = CLLocationCoordinate2D(latitude: 35.03946, longitude: 135.72956)
                annotation.title = (detail as! CollectionPoint).name
                annotation.subtitle = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
                map.addAnnotation(annotation)
                // Center the map on the annotation.
                map.setCenter(annotation.coordinate, zoomLevel: 14, animated: false)
                
                // Pop-up the callout view.
                map.selectAnnotation(annotation, animated: true, completionHandler: nil)
            }
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
}
