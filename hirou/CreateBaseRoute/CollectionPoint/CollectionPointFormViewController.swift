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
    @IBOutlet weak var cpCoordinatesLat: UITextField!
    @IBOutlet weak var cpCoordinatesLong: UITextField!
    @IBOutlet weak var cpSequence: UITextField!
    @IBOutlet var cpMapView: MGLMapView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var annotationView: MGLAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cpMapView.delegate = self
        // Do any additional setup after loading the view.
        configureView()
    }
    
    func saveCPCall() {
        let id = (detailItem as! CollectionPoint).id
        if id != -1 {
            let id = String((detailItem as! CollectionPoint).id)
            let parameters: [String: String] = [
                "name": String(self.cpNameLabel.text!),
                "location": self.cpCoordinatesLat.text! + "," + self.cpCoordinatesLong.text! ,
                "address": self.cpAddressLabel.text ?? "nil",
                "sequence": self.cpSequence.text ?? "0"
            ]
            AF.request("http://127.0.0.1:8000/api/collection_point/"+String(id)+"/", method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)

                    case .failure(let error):
                        print(error)
                    }
            }
        } else {
            let routeId = (detailItem as! CollectionPoint).route
            let parameters: [String: String] = [
                "name": String(self.cpNameLabel.text!),
                "location": self.cpCoordinatesLat.text! + "," + self.cpCoordinatesLong.text! ,
                "address": self.cpAddressLabel.text ?? "nil",
                "route": String(routeId),
                "sequence": self.cpSequence.text ?? "0"
            ]
            AF.request("http://127.0.0.1:8000/api/collection_point/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    func deleteCPCall() {
        if let detail = detailItem {
            let id = (detail as! CollectionPoint).id
            AF.request("http://127.0.0.1:8000/api/collection_point/"+String(id)+"/", method: .delete)
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        _ = self.navigationController?.popViewController(animated: true)
                        //                        self.customers = []
                        
                    case .failure(let error):
                        print(error)
                        //                completion(nil)
                    }
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Collection Point ?", message: "Are you sure you want to delete the collection point ?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes. Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteCPCall()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No. Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        saveCPCall()
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
            
            if let label = self.cpCoordinatesLat {
                label.text = String((detail as! CollectionPoint).location.latitude)
            }
            
            if let label = self.cpCoordinatesLong {
                label.text = String((detail as! CollectionPoint).location.longitude)
            }
            
            if let label = self.cpSequence {
                label.text = String((detail as! CollectionPoint).sequence )
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
            
            if (detail as! CollectionPoint).id == -1 {
                if let button = self.deleteButton {
                    button.isHidden = true
                }
                
                if let button = self.saveButton {
                    button.setTitle("Add", for: .normal)
                }
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
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
//
        // For better performance, always try to reuse existing annotations. To use multiple different annotation views, change the reuse identifier for each.
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "draggablePoint") {
            return annotationView
        } else {
//            return DraggableAnnotationView(reuseIdentifier: "draggablePoint", size: 20)
//            return MGLAnnotationView(annotation: annotation, reuseIdentifier: "draggablePoint" )
            self.annotationView = DraggableAnnotationView(annotation: annotation as! MGLPointAnnotation, reuseIdentifier: "draggablePoint", size: 20)
            return self.annotationView
        }
    }
}
