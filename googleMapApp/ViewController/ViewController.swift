//
//  ViewController.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 06/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    @IBOutlet var MapView: GMSMapView!

    @IBOutlet var geoLocationLabel: UILabel!
    @IBOutlet weak var geoLocationView: UIView!
    @IBOutlet weak var placeMaker: UIImageView!
    private let dataProvider = GoogleDataProvider()
    private let locationManager = CLLocationManager()
    private let searchRadius: Double = 2000
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    
    struct StroryBoardID {
        static let AROUNRVCID = "aroudmeSegueID"
    }
    //MARK: View Did Load
    override func viewDidLoad() {
        
        //Call CLLocationManager Delegate to fetch updated location and show it in the mapview
        self.CustomizeMap()
        locationManager.delegate = self
        MapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func CustomizeMap() -> Void{
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.MapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    //MARK: Segue data handling method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StroryBoardID.AROUNRVCID {
            
            let aroundvc = segue.destination as! AroundMeViewController
            aroundvc.selectedTypes = searchedTypes
            aroundvc.delegate = self
        }
    }

    private func reverseGeoCoordinate(_ coordinate:CLLocationCoordinate2D) {
        
        //Creates a GMSGeocoder object to turn a latitude and longitude coordinate into a street address
        let geocoder = GMSGeocoder()
        
        
        //Asks the geocoder to reverse geocode the coordinate passed to the method. It then verifies there is an address in the response of type GMSAddress, This is a model class for addresses returned by the GMSGeocoder
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            guard let address = response?.firstResult(),let lines = address.lines else {
                return
            }
            
            //Sets the text of the addressLabel to the address returned by the geocoder
            self.geoLocationLabel.text = lines.joined(separator: "\n")
            
            let labelHeight = self.geoLocationLabel.intrinsicContentSize.height
            self.MapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                bottom: labelHeight, right: 0)
        }
        
    }
    
    //MARK: Search button Action
    @IBAction func searchButtonAction(_ sender: Any) {
        performSegue(withIdentifier: StroryBoardID.AROUNRVCID, sender: [String]?.self)
    }
    
    //MARK: Fetch near by places
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        MapView.clear()
        
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.MapView
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
//You create a ViewController extension that conforms to CLLocationManagerDelegate.
//MARK: CLLocationManagerDelegates
extension ViewController:CLLocationManagerDelegate {
    
  //locationManager(_:didChangeAuthorization:) is called when the user grants or revokes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //Here you verify the user has granted you permission while the app is in use
        guard status == .authorizedWhenInUse else{
            return
        }
        //Once permissions have been established, ask the location manager for updates on the user’s location.
        locationManager.startUpdatingLocation()
        
        //GMSMapView has two features concerning the user’s location: myLocationEnabled draws a light blue dot where the user is located, while myLocationButton, when set to true, adds a button to the map that, when tapped, centers the map on the user’s location
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true
    }
    
    //locationManager(_:didUpdateLocations:) executes when the location manager receives new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Fetch updated location
        guard let location = locations.first else{
            return
        }
        
        //This updates the map’s camera to center around the user’s current location. The GMSCameraPosition class aggregates all camera position parameters and passes them to the map for display
        MapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        //Tell locationManager you’re no longer interested in updates; you don’t want to follow a user around as their initial location is enough for you to work with
        locationManager.stopUpdatingLocation()
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
    
    
}

extension ViewController:GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        reverseGeoCoordinate(position.target)
        self.geoLocationLabel.unlock()
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.geoLocationLabel.lock()
        if (gesture) {
            placeMaker.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        infoView.palceLabel.text = placeMarker.place.name
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "generic")
        }
        
        return infoView
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        placeMaker.fadeIn(0.25)
        MapView.selectedMarker = nil
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.placeMaker.fadeOut(0.25)
        return false
    }
}
// MARK: - TypesTableViewControllerDelegate
extension ViewController: AroundMeViewControllerDelegate {
    func typesController(_ controller: AroundMeViewController, didSelectTypes types: [String]){
        searchedTypes = controller.selectedTypes.sorted()
        controller.navigationController?.popViewController(animated: true)
        fetchNearbyPlaces(coordinate: self.MapView.camera.target)
    }
}
