//
//  AppDelegate.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 08/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var db: Firestore?
    var presentLocation: CLLocation?
    var timer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in self.updateLocationOnFirebase() })
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorizedAlways")
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("New location is \(location)")
            presentLocation = location
        }
    }
    
    func updateLocationOnFirebase() {
        guard let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.USER_ID) else {
            print("USER_ID not found :: Location not updated")
            return
        }
        
        if presentLocation == nil {
            print("Present Location not found :: Location not updated")
            return
        }
        
        let latitude = presentLocation?.coordinate.latitude
        let longitude = presentLocation?.coordinate.longitude
        
        let data: [String: Any] = [
            "id": userId,
            "latitude": latitude!,
            "longitude": longitude!,
        ]

        db?.collection(FirestoreConstants.VEHICLES).document(userId).setData(data) { err in
            if let err = err {
                print("Error updating location :: firebase write error: \(err)")
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

