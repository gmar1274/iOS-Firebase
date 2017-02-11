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
import Firebase

class MainViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource{

	@IBOutlet weak var searchLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var slideBar: UISlider!
	var radius:Int=10
	var locationManager:CLLocationManager? = nil
	var location:CLLocation?
	var selectedPosition:Int=0
	var store_list = [FirebaseStore]() //alternatively (does the same): var
	
	var alert:UIAlertController?
	var mainTabController:MainTabControllerViewController?
	
	//array = Array<Country>()
	//array.append(Country())
	
	@IBOutlet var tableView: UITableView!
	
	
	/////////////////////////////////////end variables
	@IBAction func slideBarValueChange(_ sender: UISlider) {
		radius = Int(sender.value)
		searchLabel.text = String(radius)+" mi"
	}
	
	/**
	This method clears all stores in arraylist and all annotations from mapView
	*/
	@IBAction func updateStores(_ sender: AnyObject) {
		if self.store_list != nil{
			store_list.removeAll()
		}
		if self.mapView != nil{
			mapView.removeAnnotations(mapView.annotations)
		}
		self.searchForStores()
	}
	
	/**On create load the locationManager and get location ,then send a Post request and update mapView*/
    override func viewDidLoad() {
        super.viewDidLoad()
		self.mainTabController = tabBarController as! MainTabControllerViewController
		
		if (LoginViewController.locationManager == nil){ //get location if not already have
			print("Location manager is null")
			self.dismiss(animated: true, completion: nil)
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
		// Register custom cell
		//var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
		//tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
		tableView.delegate =  self
		tableView.dataSource = self
		
		//make a POST call get all stores
		//PostRequest.store_request(self)
		searchForStores()
		
		//centerMapOnLocation(location!)
		
		        // Do any additional setup after loading the view.
    }
	func searchForStores(){
		self.clearStores()
		self.clearMapView()
		self.centerMapOnLocation(self.location!)
		 alert = UIAlertController(title: "Searching nearby shops", message: "Please wait...", preferredStyle: .alert)
		
		alert?.view.tintColor = UIColor.black
		
		let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingIndicator.startAnimating();
		
		alert?.view.addSubview(loadingIndicator)
		present(alert!, animated: true, completion: nil)//display seraching
		//let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector:#selector(self.update), userInfo: nil, repeats: true)//in seconds
		//add a query for stores
		FIRDatabase.database().reference().child("user").queryOrderedByKey().observeSingleEvent(of:FIRDataEventType.value, with: {(snapshot) in
			//let store_arr = snapshot.value as? NSArray
			
			for ds in snapshot.children{//for each store in Firebase db
				let store = FirebaseStore(snapshot: ds as! FIRDataSnapshot)
				let snap = (ds as! FIRDataSnapshot).children.allObjects as! [FIRDataSnapshot] ?? []
				for child in snap {
					let c = child as! FIRDataSnapshot
					if c.hasChildren(){
						let lat = c.childSnapshot(forPath: "latitude").value as! CDouble
						let lon = c.childSnapshot(forPath: "longitude").value as! CDouble
						store.setLocation(latlng: LatLng(lat: lat, lon: lon))
					}
					let sn = (ds as! FIRDataSnapshot).childSnapshot(forPath:"store_number").value as! CLong
					store.store_number = sn
					let tp = (ds as! FIRDataSnapshot).childSnapshot(forPath:"ticket_price").value as! CDouble
					store.ticket_price = tp
					
				}
				
				
				if Utils.isInRadiusSearch(user_loc: self.location!, store: store, miles: CDouble(self.radius)) {
					self.store_list.append(store)
					self.mapView.addAnnotation(store)
				}
				
			}//end for datasnap all list...
			self.store_list.sort(by: {$0.miles_away! < $1.miles_away!})
			self.tableView.reloadData()
			if self.store_list != nil && self.store_list.count > 0{
				self.mainTabController?.setCurrentStore(store: self.store_list[0])//by default first store
			}
			self.alert?.dismiss(animated: true, completion: nil)
			
		})//end firebase single event listener
	}
	
	func clearMapView(){
		if self.mapView.annotations != nil && self.mapView.annotations.count>0{
		 self.mapView.removeAnnotations(self.mapView.annotations)
		}
	}
	func clearStores(){
		if self.store_list != nil && self.store_list.count>0{
			self.store_list.removeAll()
		}
	}
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func reloadTable(){
		//print("Table: "+String(MainViewController.store_list.count))
		self.tableView.reloadData()
	}
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if (annotation is MKUserLocation) {
			//if annotation is not an MKPointAnnotation (eg. MKUserLocation),
			//return nil so map draws default view for it (eg. blue dot)...
			return nil
		}
		if let annotation = annotation as? FirebaseStore {
			let identifier = "pin"
			var view: MKPinAnnotationView
			if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
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
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
	             calloutAccessoryControlTapped control: UIControl) {
  let location = view.annotation as! Store
  let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
  location.mapItem().openInMaps(launchOptions: launchOptions)
	}
	
	//MARK:- Zoom to region
 
	func zoomToRegion(_ lat:Double, lon:Double) {
		
		let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
		
		let region = MKCoordinateRegionMakeWithDistance(location, 5000.0, 7000.0)
		
		mapView.setRegion(region, animated: true)
	}
	
	///////////GPS functions
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			self.location=location
			locationManager?.stopUpdatingLocation()
			print("Found user's location: in Main: \(location)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to find user's location in main: \(error.localizedDescription)")
	}
	
	///end gps
	//////////////helper function
func centerMapOnLocation(_ location: CLLocation) {
	
	mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span: MKCoordinateSpanMake(0.05, 0.05)), animated: true)
	mapView.showsUserLocation=true
	}	/////////////////
	/////debug
	func debug(){
		
	}
	
	func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
		if status == .authorizedWhenInUse{
			locationManager?.startUpdatingLocation()
		}
	}
	////end debug
	///////////////////Table view Controller
		
	 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let store = store_list[indexPath.row]
		let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
		selectedCell.contentView.backgroundColor = UIColor.gray
		selectedPosition = indexPath.row
		//print("You selected cell #\(indexPath.row)!")
		let location = CLLocation(latitude: store.location!.latitude, longitude: store.location!.longitude)
		centerMapOnLocation(location)
		self.mainTabController?.setCurrentStore(store: store)//update the controller
	}
	 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
		//get cell with ID: "Cell"
		
		let store:FirebaseStore = store_list[indexPath.row]
		cell.store_name.text = store.name
		cell.address.text = store.address!
		
		
		cell.hours.text = store.operatingHours()
		let nf = NumberFormatter()
		nf.numberStyle = .currency
		nf.currencySymbol = ""
		let dist = store.miles_away
		cell.distance.text = nf.string(from: NSNumber(value: dist!))
		
		/**let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: Selector("image"))
		
		
		cell.imageView!.addGestureRecognizer(tapGestureRecognizer)
	*/
		return cell
		
	}
	/**
	I want to open dialog that ask if they want to make a call
	*/
	func imageTapped(_ img:AnyObject) {
		
	}
	// number of rows in table view
	 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return store_list.count
	}
	
	
	// if tableView is set in attribute inspector with selection to multiple Selection it should work.
	// Just set it back in deselect
	
	 func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
		cellToDeSelect.contentView.backgroundColor = UIColor.white
		
	}
	 func getCurrentStore() -> FirebaseStore{
		return store_list[selectedPosition]
	}
	 func updateStore(_ store:FirebaseStore, index:Int){
		store_list.remove(at: index)
		store_list.insert(store, at: index)
	}
	///////////////////////end tableview controler
	/**
	if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){//ask / check for user permission
	location = (locationManager?.location)!
	}
	*/
}


