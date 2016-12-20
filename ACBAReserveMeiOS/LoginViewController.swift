//
//  ViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//
import CoreLocation
import UIKit

class LoginViewController: UIViewController, CLLocationManagerDelegate {
	@IBOutlet weak var username: UITextField!
	@IBOutlet weak var password: UITextField!
	static var locationManager: CLLocationManager? = nil
	static var location: CLLocation? = nil
	
	
	@IBAction func login(sender: AnyObject) {
		let u = username.text
		let p = password.text
		if( u?.characters.count==0 || p?.characters.count<=4){
			return
		}
		PostRequest.login_request(self, user:u!, pass:p!)
	}
	 func loginSuccess(){
		//load user credentials
		//then go to
		performSegueWithIdentifier("guest", sender:self)
	}
	func loginStylistSuccessful(){
		//go swegue to stylist 
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		LoginViewController.locationManager=CLLocationManager()
		LoginViewController.locationManager!.delegate = self
		LoginViewController.locationManager!.requestAlwaysAuthorization()
		LoginViewController.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
		LoginViewController.locationManager!.requestWhenInUseAuthorization()
		LoginViewController.locationManager!.startUpdatingLocation()
		
		
	}
	func locationManager(manager:CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
		if status == .AuthorizedWhenInUse{
			LoginViewController.locationManager?.startUpdatingLocation()
			
			
		}
	}
 func guestLogin(sender: AnyObject) {
		performSegueWithIdentifier("guest", sender:self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			print("Login class..Found user's location: \(location)")
			LoginViewController.location=location
			LoginViewController.locationManager?.stopUpdatingLocation()
		}
	}

	
	func locationManager(manager: CLLocationManager) {
		print("Failed to find user's location:..")
	}
}

