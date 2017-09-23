//
//  LocationManager.swift
//  Remind Me At
//
//  Created by Rishabh on 27/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject {
 
    //Mark: variables
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    var onLocationFix : ((CLPlacemark?,Error?) -> Void)?
    
//    So the first thing you need to do is to add one or both of the following keys to your Info.plist file:
//    •NSLocationWhenInUseUsageDescription
//    •NSLocationAlwaysUsageDescription

    
    //Mark: Init
    override init() {
        super.init()
        
        manager.delegate = self
        // for use of GPS
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.allowsBackgroundLocationUpdates = true
        
        //get location permission
        getPermission()
    }

    //Mark: Functions
    
    //Ask user permission for location
    
   /*  If your app can function with just foreground location but you have some parts that need Always (e.g. optional geofencing functionality) you would add both keys to the plist and start by requesting WhenInUse, then later asking for Always authorization. Unfortunately, this isn’t as simple as just calling [self.locationManager requestAlwaysAuthorization] at some later point (after getting WhenInUse authorization). Unless the user has never been asked for authorization (kCLAuthorizationStatusNotDetermined) you have to ask them to change it manually in the Settings.*/
    
    fileprivate func getPermission(){
        if CLLocationManager.authorizationStatus() == .notDetermined{
            manager.requestAlwaysAuthorization()
        }
        }
    
    // Reverse Location
    func reverseLocation(location:Location, completion: @escaping(_ city:String, _ street: String) -> Void) {
        
        let locationToReverse = CLLocation(latitude:location.latitude, longitude:location.longitude)
        self.geocoder.reverseGeocodeLocation(locationToReverse) {
            placemarks, error in
            
            if let placemark = placemarks?.first {
                
                guard let city = placemark.locality, let street = placemark.thoroughfare else {
                    return
                }
                
                completion(city, street)
            }
        }
    }
    
    // parde location address
    func parseAdress(location:MKPlacemark) -> String{
        let firstSpace = (location.subThoroughfare != nil && location.thoroughfare != nil) ? " " : ""
        
        // put a coma between street & city/state
        let comma = (location.subThoroughfare != nil && location.thoroughfare != nil) && (location.subAdministrativeArea != nil || location.administrativeArea != nil) ? ", " : ""
        
        let secondSpace = (location.subAdministrativeArea != nil && location.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@",
            //street number
            location.subThoroughfare ?? "",firstSpace,
            // street name
            location.thoroughfare ?? "",comma,
            //city
            location.locality ?? "",secondSpace,
            //state
            location.administrativeArea ?? ""
            )
        return addressLine
    }
    
    // drop pin on the map at the selected location and add overlay
    func dropPinZoomIn(placemark:MKPlacemark, mapView: MKMapView){
        
        //clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let location = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        mapView.add(MKCircle(center: location.coordinate, radius: 50))
    }
}

//Mark: Extension
extension LocationManager: CLLocationManagerDelegate{
    
    //Mark: location delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       
        if status == .authorizedAlways {
         manager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        guard let location = locations.first else{
            return
        }
        
        geocoder.reverseGeocodeLocation(location){
            placemarks, error in
            
            if let onLocationFix = self.onLocationFix {
                onLocationFix(placemarks?.first, error)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("unresolved error: \(error) ")
    }
}
