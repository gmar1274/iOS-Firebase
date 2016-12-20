//
//  PostRequest.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
import CoreLocation
class PostRequest{
	static let loginURL:String="http://www.acbasoftware.com/pos/login.php?"
	static let stylistURL:String="http://www.acbasoftware.com/pos/stylist.php?"
	static let upload_imageURL:String="http://www.acbasoftware.com/pos/upload_image.php?"
	static let lockDBURL:String="http://www.acbasoftware.com/pos/lockdb.php?"
	static let storeURL:String="http://www.acbasoftware.com/pos/store.php?"
	static let servicesURL:String="http://www.acbasoftware.com/pos/services.php?"
	static let reservationURL:String="http://www.acbasoftware.com/pos/reservation.php?"
	static let appointmentURL:String="http://www.acbasoftware.com/pos/appointment.php?"
	
	/**
	Method not implemented.. Change parameters
	*/
	static func store_request(mvc:MainViewController)
	{
		
		var param:String="store="+("acbastorelistacba").sha1()
		param += "&lat="+String(mvc.location!.coordinate.latitude)
		param += "&lon="+String(mvc.location!.coordinate.longitude)
		param += "&radius="+String(mvc.radius)
		
		let url:NSURL = NSURL(string: storeURL)!
		let session = NSURLSession.sharedSession()
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
		
		request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) {
			(
			let data, let response, let error) in
			
			guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
				return
			}
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!,options: .AllowFragments)
				if let stores = json["store"] as? [[String: AnyObject]]{
					for jObj in stores{///////////////////////for loop
						let name = jObj["Store"] as! String
						let google_id=String(jObj["google_place_id"] )
						let address = String( String(jObj["Address"]))
						let city = String(jObj["city"])
						let state = String(jObj["state"])
						let zip = String(jObj["zip"])
						let phone = String(jObj["phone"] as! String)
						let ticket_price = Double(String(jObj["ticket_price"] as! String))
						let reservation_price = Double(String(jObj["reservation_price"] as! String))
						let open = String(jObj["open_time"]) //time -string format
						let close = String(jObj["close_time"]) //time- string formart 12:00:00 ex
						let lat = Double(String(jObj["lat"] as! String))
						let lon = Double(String(jObj["lon"] as! String))
						let distance = Double(String(jObj["distance"] as! String))//dynamic variable
						let cord = CLLocationCoordinate2D(latitude: lat!,longitude: lon!)
						
						var store=Store(title: name,locationName:address, coordinate:cord )//add annotation
						store.setVariables(name, id: google_id, address: address, city: city, state: state, zip: zip, ticket_price: ticket_price!, rservation_price: reservation_price!,open: open,close:close,distance:distance!)
						MainViewController.store_list.append(store)//add to list
						mvc.mapView.addAnnotation(store)
					}/////////////////////////end for
					mvc.centerMapOnLocation(mvc.location!)
					//NSOperationQueue.mainQueue().addOperationWithBlock {	//call back to main thread
				//		mvc.debug()//mvc.loginSuccess()
				//	}
					
				}
				
				
			}catch {
				print("no json..err")			}
		}
		
		task.resume()
	}
	func getNSDateTime(date:String)->NSDate{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		var date = dateFormatter.dateFromString(date) as NSDate!
		let outputDate = dateFormatter.stringFromDate(date)
		print(outputDate)
		return date
	}
	func getNSDate(date:String)->NSDate{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		var date = dateFormatter.dateFromString(date) as NSDate!
		let outputDate = dateFormatter.stringFromDate(date)
		print(outputDate)
		return date
	}/**
	Method not implemented.. Change parameters
	*/
	static func services_request(lvc:LoginViewController,user:String,pass:String)
	{
		
		var param:String="login="+("acbaloginacba").sha1()+"&username="+user+"&password="+(pass).sha1()
		let url:NSURL = NSURL(string: loginURL)!
		let session = NSURLSession.sharedSession()
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
		
		request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) {
			(
			let data, let response, let error) in
			
			guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
				return
			}
			
			do{
				let json = try NSJSONSerialization.JSONObjectWithData(data!,options: .AllowFragments)
				if let stores = json["store"] as? [[String: AnyObject]]{
					for jObj in stores{
						///
					}
				}
				
				
			}catch {
				print("no json..err")			}
			
		}
		
		task.resume()
		
	}
	
	
	/**
	Method not implemented.. Change parameters
	*/
	static func stylist_request(lvc:LoginViewController,user:String,pass:String)
	{
		
		var param:String="login="+("acbaloginacba").sha1()+"&username="+user+"&password="+(pass).sha1()
		let url:NSURL = NSURL(string: loginURL)!
		let session = NSURLSession.sharedSession()
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
		
		request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) {
			(
			let data, let response, let error) in
			
			guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
				return
			}
			
			//let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
			
			do{
				let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!,options: .AllowFragments)
				
				let response: String = (jsonObject!["status"]) as! String
				if(response=="true"){
					NSOperationQueue.mainQueue().addOperationWithBlock {	//call back to main thread
						lvc.loginSuccess()
					}
				}
				
			}catch {
				print("no json..err")			}
			
		}
		
		task.resume()
		
	}
	
	
	static func login_request(lvc:LoginViewController,user:String,pass:String)
	{
		
		var param:String="login="+("acbaloginacba").sha1()+"&username="+user+"&password="+(pass).sha1()
		let url:NSURL = NSURL(string: loginURL)!
		let session = NSURLSession.sharedSession()
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
		
		request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) {
			(
			let data, let response, let error) in
			
			guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
				return
			}
			
	//let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
			
			do{
				let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!,options: .AllowFragments)
			
				let response: String = (jsonObject!["status"]) as! String
				if(response=="true"){
					 NSOperationQueue.mainQueue().addOperationWithBlock {	//call back to main thread
						lvc.loginSuccess()
					}
				}
				
			}catch {
				print("no json..err")			}
			
		}
		
		task.resume()
		
	}
	
	func getJSON(urlToRequest: String) -> NSData{
		return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
	}
	
	func parseJSON(inputData: NSData) -> NSDictionary{
		var error: NSError?
		do{
		let boardsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
			return boardsDictionary
		}catch{
			
		}
		let b:NSDictionary?=nil
		return b!
	}
	


}
