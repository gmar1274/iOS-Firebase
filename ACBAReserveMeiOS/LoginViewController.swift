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
import GoogleMobileAds
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


class LoginViewController: UIViewController, CLLocationManagerDelegate, GADBannerViewDelegate,GADInterstitialDelegate {
	
	var TEST:Bool = true
	
	@IBOutlet var username: UITextField!
	
	@IBOutlet var password: UITextField!
	
	 var locationManager: CLLocationManager? = nil
	 var location: CLLocation? = nil
	
	 var store_id:CLong = -1
	 var stylist_id:String = ""
	@IBAction func login(_ sender: AnyObject) {
		let u = username.text
		let p = password.text
		if( u?.characters.count==0 || p?.characters.count<=4){
			self.error(msg:"Enter a username and password.")
			return
		}else{
			let username = u?.replacingOccurrences(of: " ", with: "")
			var alert = UIAlertController(title: "Authenticating", message: "Please wait...", preferredStyle: .alert)
			
			alert.view.tintColor = UIColor.black
			
			let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
			loadingIndicator.hidesWhenStopped = true
			loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
			loadingIndicator.startAnimating();
			
			alert.view.addSubview(loadingIndicator)
			present(alert, animated: true, completion: nil)//display Alert
			FIRAuth.auth()?.signInAnonymously(completion:{
				(user,error) in
				if(error==nil){//PostRequest.login_request(self, user:username!, pass:p!)
					
					self.firebaseQueryStylist(username: username!, pass: p!, alert:alert)
					
				}else{//error cant login probably network off
					
			}
			})//end sign anon
			
		}//end else
	}
	
	func firebaseQueryStylist(username:String, pass:String, alert:UIAlertController){
		let password = pass.sha1()//encrypted pass
		var user:FirebaseEmployee?
		let ref = FIRDatabase.database().reference().child("employees")
		ref.queryOrderedByKey().observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
			for ds in snapshot.children{
				
				let emp = FirebaseEmployee(snapshot: ds as! FIRDataSnapshot)
				if emp.app_username == username && password == emp.app_password{
					user = emp
					break
				}
			}
			
			alert.dismiss(animated: false, completion: { a in
				if user == nil{
					self.error(msg: "Username or password is invalid...")
				}else{
					self.goToEmployeeActivity(user: user!)
				}
			})
			
			
			/*let arr = snapshot.value as? [[String:AnyObject]]
			if (arr?.count)! > 0{
			
			}else{
				alert.dismiss(animated: true, completion: nil)
				self.error(msg: "Username or password is invalid.")
			}*/
		})
		/*var arr:[[String: AnyObject]] = []
		var dict:[String:AnyObject] = [:]
		dict["name"] = "Gabriel Martinez" as AnyObject?
		dict["id"] = "1212"as AnyObject?
		dict["app_password"] = "12345".sha1() as AnyObject?
		dict["app_username"] = "gmar1274" as AnyObject?
		dict["store_number"] = "41" as AnyObject?
		dict["store_phone"] = "9091234567" as AnyObject?
		arr.append(dict)
		var dictt:[String:AnyObject] = [:]
		dictt["name"] = "Daniel Martinez" as AnyObject?
		dictt["id"] = "1234"as AnyObject?
		dictt["app_password"] = "12345".sha1() as AnyObject?
		dictt["app_username"] = "dmar1274" as AnyObject?
		dictt["store_number"] = "41" as AnyObject?
		dictt["store_phone"] = "9091234567" as AnyObject?
		arr.append(dictt)
		
		ref.setValue(arr)*/
		
	}
	func goToEmployeeActivity(user:FirebaseEmployee){
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "stylist_tbc") as! CustomTabBarController
		vc.employee = user
		vc.selectedIndex = 0
		self.present(vc, animated: false, completion: nil)
		
	}
	
	////GO TO MAIN MENU. FIREBASE LOGIN IN AS ANON
	 func loginSuccess(){
		//load user credentials
		//then go to
		//performSegue(withIdentifier: "guest", sender:self)
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabcontroller") as! MainTabControllerViewController
		vc.location = self.location
		vc.locationManager = self.locationManager
		self.present(vc, animated: false, completion: nil)
		
		
	}
	func stylistScreen(store_id:CLong, stylist_id:String){
		let vc = storyboard?.instantiateViewController(withIdentifier: "stylist_tbc") as! CustomTabBarController
		vc.sty_id = self.stylist_id
		vc.store_id = self.store_id.description
		self.present(vc, animated: true, completion: nil)
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
	
	
	@IBOutlet var adBannerView: GADBannerView!
	func error(msg:String){
		
		let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		self.present(alertController, animated: true, completion:nil)
		
	}
	var interstitial:GADInterstitial!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.TEST = true
		locationManager=CLLocationManager()
		locationManager!.delegate = self
		locationManager!.requestAlwaysAuthorization()
		locationManager!.desiredAccuracy = kCLLocationAccuracyBest
		locationManager!.requestWhenInUseAuthorization()
		locationManager!.startUpdatingLocation()
		
		
		//adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
		/** for banner
		App ID: ca-app-pub-9309556355508377~2611344846
		Ad unit ID: ca-app-pub-9309556355508377/2192542441
		*/
		interstitial = self.createAndLoadInterstitial()
		self.adBannerView.isHidden = true
		self.adBannerView.delegate = self
		self.adBannerView.adSize = kGADAdSizeSmartBannerPortrait
		adBannerView.adUnitID = "ca-app-pub-9309556355508377/2192542441"
		adBannerView.rootViewController = self
		//adBannerView =  GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
		//adBannerView.frame = CGRect(x: adBannerView.frame.minX, y: adBannerView.frame.minX, width: 320, height: 50)
		var request:GADRequest = GADRequest()
		
		if TEST{
		    request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
		}
		 		adBannerView.load(request)
		
	}
	func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
		print("ad loaded ")
		self.adBannerView.isHidden = false
	}
	func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
		print("ERRRRR: \(error)")
		self.adBannerView.isHidden = true
	}
	func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
		if status == .authorizedWhenInUse{
			locationManager?.startUpdatingLocation()
			
			
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
		if self.interstitial.isReady{
			self.interstitial.present(fromRootViewController: self)
		}
	}
	
	func createAndLoadInterstitial() -> GADInterstitial {
		//for video
		//app ID: ca-app-pub-3940256099942544/2934735716
		//Ad unit ID: ca-app-pub-9309556355508377/4088078044
         var interstitial = GADInterstitial(adUnitID: "ca-app-pub-9309556355508377/4088078044")
         interstitial.delegate = self
		var request = GADRequest()
		
		if TEST{
			request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
		}
		interstitial.load(request)
		return interstitial
	}
	
	func interstitialDidDismissScreen(_ ad: GADInterstitial) {
		self.loginSuccess()
		interstitial = createAndLoadInterstitial()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			//print("Login class..Found user's location: \(location)")
			self.location=location
			locationManager?.stopUpdatingLocation()
		}else{
			//no location found
		}
	}

	
	func locationManager(_ manager: CLLocationManager) {
		print("Failed to find user's location:..")
	}
}

