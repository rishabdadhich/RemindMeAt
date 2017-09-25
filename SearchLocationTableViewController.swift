//
//  SearchLocationTableViewController.swift
//  Remind Me At
//
//  Created by Rishabh on 31/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

//---------------------
//MARK: Protocol
//---------------------
protocol writeLocationBackDelegate: class {
    func writeLocationBack(toLocation: CLLocation, event: String)
}


class SearchLocationTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating {
    
    //---------------------
    //MARK: Variables
    //---------------------
    var searchController: UISearchController!
    let locationManager = LocationManager()
    let coreDataManager = CoreDataManager()
    var reminder: Reminder?
    var locations: [MKMapItem] = []
    var locationToPassBack: CLLocation?
    var event = "Leaving"
    weak var delegate: writeLocationBackDelegate?
    
    //Mark: outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "CurrentLocation-1"), style: .plain, target: self, action: #selector(zoomToCurrentLocation))
        
        
        configureSearchController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let location = self.locationToPassBack {
            delegate?.writeLocationBack(toLocation: location, event: event)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mapView.removeFromSuperview()
        mapView = nil
    }
    
    deinit {
        searchController.view.removeFromSuperview()
        mapContainerView.removeFromSuperview()
        segmentControl.removeFromSuperview()
        mapView = nil
    }
    
    //Mark:button action
    
    @IBAction func eventChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.event = "Arriving"
        case 1 :
            self.event = "Leaving"
        default:
            break
        }
    }
    
    
    
    
    
    //Mark: tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let location = locations[indexPath.row].placemark
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = locationManager.parseAdress(location: location)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapContainerView.isHidden = false
        searchController.searchBar.endEditing(true)
        
        let selectedLocation = locations[indexPath.row].placemark
        locationManager.dropPinZoomIn(placemark: selectedLocation, mapView: self.mapView)
        print(selectedLocation.coordinate)
        print(selectedLocation.name!)
        
        locationToPassBack = CLLocation(latitude: selectedLocation.coordinate.latitude, longitude: selectedLocation.coordinate.longitude)
    }
    
    //Mark: search
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else{
            return
        }
        self.getLocations(forSearchString: text)
    }
    
    fileprivate func getLocations(forSearchString searchString:String){
        
        let request = MKLocalSearchRequest()
        // ativity indicator start
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        request.naturalLanguageQuery = searchString
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            
            guard error == nil else{
                
                return
            }
            
            guard let response = response else{
                // alert in case geocode fails
                
                let alert = UIAlertController(title: "", message: "Unable to geocode.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.locations = response.mapItems
            self.tableView.reloadData()
            
            //activity indicator stops
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    @objc func zoomToCurrentLocation() {
        mapContainerView.isHidden = false
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.userLocation.coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span)
        mapView.setRegion(region
            , animated: true)
        
        let location = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        mapView.add(MKCircle(center: location.coordinate, radius: 50))
        
        locationToPassBack = location
        
    }
    
    //Mark: functions
    func configureSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search or Enter Address"
        searchController.searchBar.showsCancelButton = false
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white], for: .normal)
        
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
    }
    
}
extension SearchLocationTableViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 2.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
