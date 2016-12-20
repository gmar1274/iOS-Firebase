//
//  MainViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

	@IBOutlet weak var searchLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var slideBar: UISlider!
	var radius:Int=10
	var locationManager:CLLocationManager? = nil
	var location:CLLocation?
	static var selectedPosition:Int=0
	static var store_list = [Store]() //alternatively (does the same): var array = Array<Country>()
	//array.append(Country())
	
	
	
	/////////////////////////////////////end variables
	@IBAction func slideBarValueChange(sender: UISlider) {
		radius = Int(sender.value)
		searchLabel.text = String(radius)+" mi"
	}
	
	/**
	This method clears all stores in arraylist and all annotations from mapView
	*/
	@IBAction func updateStores(sender: AnyObject) {
		MainViewController.store_list.removeAll()
		mapView.removeAnnotations(mapView.annotations)
		PostRequest.store_request(self)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if (LoginViewController.locationManager == nil){ //get location if not already have
			print("Location manager is null")
			locationManager=CLLocationManager()
			locationManager!.delegate = self
			locationManager!.requestAlwaysAuthorization()
			locationManager!.desiredAccuracy = kCLLocationAccuracyBest
			locationManager!.requestWhenInUseAuthorization()
			locationManager!.startUpdatingLocation()
			
		}else{
			locationManager = LoginViewController.locationManager
			location = LoginViewController.location
		}
		
		self.mapView.delegate=self
		//make a POST call get all stores
		PostRequest.store_request(self)
		//centerMapOnLocation(location!)
		
		        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if (annotation is MKUserLocation) {
			//if annotation is not an MKPointAnnotation (eg. MKUserLocation),
			//return nil so map draws default view for it (eg. blue dot)...
			return nil
		}
		if let annotation = annotation as? Store {
			let identifier = "pin"
			var view: MKPinAnnotationView
			if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
				as? MKPinAnnotationView { // 2
				dequeuedView.annotation = annotation
				view = dequeuedView
			} else {
				// 3
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				//view.calloutOffset = CGPoint(x: -5, y: 5)
				
			}
			return view
		}
		return nil
	
}
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
	             calloutAccessoryControlTapped control: UIControl) {
  let location = view.annotation as! Store
  let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
  location.mapItem().openInMapsWithLaunchOptions(launchOptions)
	}
	
	//MARK:- Zoom to region
 
	func zoomToRegion(lat:Double, lon:Double) {
		
		let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
		
		let region = MKCoordinateRegionMakeWithDistance(location, 5000.0, 7000.0)
		
		mapView.setRegion(region, animated: true)
	}
	
	///////////GPS functions
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			self.location=location
			locationManager?.stopUpdatingLocation()
			print("Found user's location: in Main: \(location)")
		}
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("Failed to find user's location in main: \(error.localizedDescription)")
	}
	
	///end gps
	//////////////helper function
func centerMapOnLocation(location: CLLocation) {
	
	mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span: MKCoordinateSpanMake(0.05, 0.05)), animated: true)
	mapView.showsUserLocation=true
	}	/////////////////
	/////debug
	func debug(){
		print("Array size: "+String(MainViewController.store_list.count))
		for item in MainViewController.store_list {
			print("Store: "+item.name!)
		}
	}
	
	func locationManager(manager:CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
		if status == .AuthorizedWhenInUse{
			locationManager?.startUpdatingLocation()
		}
	}
	
	
	/////end debug
	/**
	if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){//ask / check for user permission
	location = (locationManager?.location)!
	}
	*/
}


