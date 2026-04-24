//
//  LocationPickerExtension.swift
//  PIC
//
//  Created by Adeel on 6/13/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var locationCompletion: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            // Failed to get the user's location
            locationCompletion?(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user's location"]))
            return
        }
        
        // Pass the location data back to the completion closure
        locationCompletion?(location.coordinate, nil)
    }
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Pass the error back to the completion closure
        locationCompletion?(nil, error)
    }
}
