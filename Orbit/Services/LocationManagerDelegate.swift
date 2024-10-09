//
//  LocationManagerDelegate.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-08.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(latitude: Double, longitude: Double)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?  // Delegate to inform about location updates

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            let userLatitude = location.coordinate.latitude
            let userLongitude = location.coordinate.longitude

            // Notify delegate (UserViewModel) of new location
            delegate?.didUpdateLocation(
                latitude: userLatitude, longitude: userLongitude)
        }
    }
}
