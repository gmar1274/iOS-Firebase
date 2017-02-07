//
//  ViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//
import CoreLocation
import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class LoginViewController: UIViewController, CLLocationManagerDelegate {
	
	
	@IBOutlet var username: UITextField!
	
	@IBOutlet var password: UITextField!
	
	static var locationManager: CLLocationManager? = nil
	static var location: CLLocation? = nil
	
	static var store_id:CLong = -1
	static var stylist_id:String = ""
	@IBAction func login(_ sender: AnyObject) {
		let u = username.text
		let p = password.text
		if( u?.characters.count==0 || p?.characters.count<=4){
			self.error(msg:"Enter a username and password.")
			return
		}else{
			let username = u?.replacingOccurrences(of: " ", with: "")
			PostRequest.login_request(self, user:username!, pass:p!)
		}
	}
	 func loginSuccess(){
		//load user credentials
		//then go to
		performSegue(withIdentifier: "guest", sender:self)
	}
	func stylistScreen(store_id:CLong, stylist_id:String){
		let vc = storyboard?.instantiateViewController(withIdentifier: "stylist_tbc")
		LoginViewController.store_id = store_id
		LoginViewController.stylist_id = stylist_id
		self.present(vc!, animated: true, completion: nil)
		//performSegue(withIdentifier: "stylist", sender: self)
		//go swegue to stylist 
		//performSegue(withIdentifier: "stylist", sender: self)
	}
	func error(){
		
		let alertController = UIAlertController(title: "Error", message: "Invalid username or password", preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		self.present(alertController, animated: true, completion:nil)
	
	}
	func error(msg:String){
		
		let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		self.present(alertController, animated: true, completion:nil)
		
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		LoginViewController.locationManager=CLLocationManager()
		LoginViewController.locationManager!.delegate = self
		LoginViewController.locationManager!.requestAlwaysAuthorization()
		LoginViewController.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
		LoginViewController.locationManager!.requestWhenInUseAuthorization()
		LoginViewController.locationManager!.startUpdatingLocation()
		
		
	}
	func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
		if status == .authorizedWhenInUse{
			LoginViewController.locationManager?.startUpdatingLocation()
			
			
		}
	}
 func guestLogin(_ sender: AnyObject) {
	FIRAuth.auth()?.signInAnonymously(completion:{
		(user,error) in
		if(error==nil){
			self.goToMainActivity()
		}else{//error cant login probably network off
			
		}
	})//end sign anon
	
	}
	func goToMainActivity(){
		performSegue(withIdentifier: "guest", sender:self)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			//print("Login class..Found user's location: \(location)")
			LoginViewController.location=location
			LoginViewController.locationManager?.stopUpdatingLocation()
		}else{
			//no location found
		}
	}

	
	func locationManager(_ manager: CLLocationManager) {
		print("Failed to find user's location:..")
	}
}

