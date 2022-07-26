//
//  CollectionPointFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 02/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class CollectionPointFormViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet weak var cpNameLabel: UITextField!
    @IBOutlet weak var cpAddressLabel: UITextField!
    @IBOutlet weak var cpSequence: UITextField!
    @IBOutlet weak var cpMemo: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: ImagePicker!
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cpSequence?.isEnabled = false
        
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        configureView()
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    func didSelect(image: UIImage?) {
        self.imageView.image = image
        self.selectedImage = image
    }
    
    func updateComplete() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func saveImage(id: Int) {
        let image = self.selectedImage
        
        if image == nil {
            updateComplete()
            return
        }
        
        let imgData = image!.jpegData(compressionQuality: 0.2)!
        //         let params = ["name": "rname"] //Optional for extra parameter
        let headers = APIHeaders.getHeaders()
        
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imgData, withName: "image", fileName: String(id)+".png", mimeType: "image/png")
        },
        to: Environment.SERVER_URL + "api/collection_point/"+String(id)+"/",
        method: .patch,
        headers: headers
        )
        .validate()
        .uploadProgress( queue: .main, closure: {
            progress in
            print("Upload Progress: \(progress.fractionCompleted)")
            if progress.fractionCompleted == 1 {
                self.updateComplete()
            }
        }).responseJSON(completionHandler: { data in
            print("upload finished: \(data)")
            self.updateComplete()
        }).response { (response) in
            switch response.result {
            case .success(let result):
                print("upload success result: \(String(describing: result))")
            case .failure(let err):
                print("upload err: \(err)")
            }
        }
    }

    @objc
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.cpNameLabel.resignFirstResponder()
        self.cpAddressLabel.resignFirstResponder()
        self.cpMemo.resignFirstResponder()
    }
    
    func saveCPCall() {
        let cp = (detailItem as! CollectionPoint)
        
        let id = cp.id
        if id != -1 {
            let id = String((detailItem as! CollectionPoint).id)
            let parameters: [String: String] = [
                "name": String(self.cpNameLabel.text!),
                "address": self.cpAddressLabel.text ?? "",
                "memo": self.cpMemo.text ?? "",
                "sequence": self.cpSequence.text ?? "0"
            ]
            let headers = APIHeaders.getHeaders()
            AF.request(Environment.SERVER_URL + "api/collection_point/"+String(id)+"/", method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let value):
                        let id = ((value as AnyObject)["id"] as! Int)
                        self.saveImage(id: id)

                    case .failure(let error):
                        print(error)
                    }
            }
        } else {
            let routeId = cp.route
            let location = cp.location.latitude + "," + cp.location.longitude

            let parameters: [String: String] = [
                "name": String(self.cpNameLabel.text!),
                "location": location,
                "address": self.cpAddressLabel.text ?? "",
                "memo": self.cpMemo.text ?? "",
                "route": String(routeId),
                "sequence": self.cpSequence.text ?? "0"
            ]
            let headers = APIHeaders.getHeaders()
            AF.request(Environment.SERVER_URL + "api/collection_point/", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
                .validate()
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let value):
                        guard
                            let id = ((value as AnyObject)["id"] as? Int)
                        else {
                            let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        self.saveImage(id: id)
                        
                    case .failure(let error):
                        let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in return }))
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    func deleteCPCall() {
        if let detail = detailItem {
            let id = (detail as! CollectionPoint).id
            let headers = APIHeaders.getHeaders()
            AF.request(Environment.SERVER_URL + "api/collection_point/"+String(id)+"/", method: .delete, headers: headers)
                .validate()
                .responseString {
                    response in
                    switch response.result {
                    case .success(let value):
                        print("value", value)
                        self.updateComplete()
                        
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "収集ポイントの削除?", message: "収集ポイントを削除してもよろしいですか？", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "削除", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteCPCall()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Delte cancelled by the user.")
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if self.cpNameLabel.text!.count == 0 {
            let nameAlert = UIAlertController(title: "Collection Point name empty !!", message: "Please enter name of the collection point.", preferredStyle: .alert)
            nameAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Please enter a name")
            }))
            self.present(nameAlert, animated: true, completion: nil)
        } else {
            saveCPCall()
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
            let collectionPoint = detail as! CollectionPoint
            if let label = self.cpNameLabel {
                label.text = collectionPoint.name
            }
            
            if let label = self.cpAddressLabel {
                label.text = collectionPoint.address
            }
            
            if let label = self.cpMemo {
                label.text = collectionPoint.memo
            }
            
            if let label = self.cpSequence {
                label.text = String(collectionPoint.sequence )
            }
            
            if let image = self.imageView {
                if collectionPoint.image != nil {
//                    image.image = UIImage(systemName: "house")
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

            if collectionPoint.id == -1 {
                if let button = self.deleteButton {
                    button.isEnabled = false
                }
            }
        }
    }
}
