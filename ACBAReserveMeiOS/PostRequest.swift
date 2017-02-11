//
//  PostRequest.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
import CoreLocation
class PostRequest {
	static let loginURL:String="http://www.acbasoftware.com/pos/login.php?"
	static let stylistURL:String="http://www.acbasoftware.com/pos/stylist.php?"
	static let upload_imageURL:String="http://www.acbasoftware.com/pos/upload_image.php?"
	static let lockDBURL:String="http://www.acbasoftware.com/pos/lockdb.php?"
	static let storeURL:String="http://www.acbasoftware.com/pos/store.php?"
	static let servicesURL:String="http://www.acbasoftware.com/pos/services.php?"
	static let reservationURL:String="http://www.acbasoftware.com/pos/reservation.php?"
	static let appointmentURL:String="http://www.acbasoftware.com/pos/appointment.php?"
	
	static func createCharge(token:String){
		
	}
	//////////////api protocol
	
	
	
	
	
	
	
	
	/**
	Method makes a POST call to store.php. Then parses json object then uploads
	obj to tableView in MainViewController
	*/
	static func store_request(_ mvc:MainViewController)
	{
		
		var param:String="store="+("acbastorelistacba").sha1()
		param += "&lat="+String(mvc.location!.coordinate.latitude)
		param += "&lon="+String(mvc.location!.coordinate.longitude)
		param += "&radius="+String(mvc.radius)
		
		let url:URL = URL(string: storeURL)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler:{
			
			
			(data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			do{
				let json = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject]
				if let stores = json["store"] as? [[String: AnyObject]]{
					
					for jObj in stores{///////////////////////for loop
						let name = jObj["Store"] as? String
						let google_id = jObj["google_place_id"] as? String
						let address = jObj["Address"] as? String
						let city = jObj["city"] as? String
						let state = jObj["state"] as? String
						let zip = jObj["zip"] as? String
						let phone = jObj["phone"] as? String
					
						
						let ticket_price = Double((jObj["ticket_price"] as? String)!)
						let reservation_price = Double((jObj["reservation_price"] as? String)!)
						let open = jObj["open_time"] as? String //time -string format
						let close = jObj["close_time"] as? String//time- string formart 12:00:00 ex
						let lat = Double((jObj["lat"] as? String)!)
						let lon = Double((jObj["lon"] as? String)!)
						let distance = Double((jObj["distance"] as? String)!)//dynamic variable
						let cord = CLLocationCoordinate2D(latitude: lat!,longitude: lon!)
						
						var store=Store(title: name,locationName:address, coordinate:cord )//add annotation
						store.setVariables(name, id: google_id, address: address, city: city, state: state, zip: zip, ticket_price: ticket_price!, reservation_price: reservation_price!,open: open,close:close,distance:distance,phone:phone)
						//MainViewController.store_list.append(store)//add to list
						mvc.mapView.addAnnotation(store)
					}/////////////////////////end for
					mvc.centerMapOnLocation(mvc.location!)
					mvc.reloadTable()
					mvc.tableView.reloadData()
					//NSOperationQueue.mainQueue().addOperationWithBlock {	//call back to main thread
				//		mvc.debug()//mvc.loginSuccess()
				//	}
					
				}
				
				
			}catch {
				print("no json..err")			}
		}) 
		
		task.resume()
	}
	func getNSDateTime(_ date:String)->Date{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.date(from: date) as Date!
		let outputDate = dateFormatter.string(from: date!)
		//print(outputDate)
		return date!
	}
	func getNSDate(_ date:String)->Date{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let date = dateFormatter.date(from: date) as Date!
		let outputDate = dateFormatter.string(from: date!)
		//print(outputDate)
		return date!
	}
	
	/**
	This method fetches the stylist and the services offered by the selected store.
	Parses the responses by the services and the stylists.
	Loads
	*/
	
	static func stylist_request(_ lf:LiveFeed,store:Store)
	{
		var df = DateFormatter()//format date
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		var param:String="stylist="+("acbastylistlistacba").sha1()
		param += "&date="+df.string(from: Date())
		param += "&store_id="+store.phone!
		param += "&phone="+store.phone!
				let url:URL = URL(string: stylistURL)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler: {
			(
			data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			do{
				let json = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject]
				//var store = MainViewController.getCurrentStore()
			
				if let stores = json["stylist_names"] as? [[String: AnyObject]]{
					for jObj in stores{///////////////////////for loop
						let fname = jObj["fname"] as? String
						let mname = jObj["mname"] as? String
						let lname = jObj["lname"] as? String
						let name = Utils.formatName(fname, mname: mname, lname: lname)
						
						let phone = jObj["phone"] as? String
						
						let avail = jObj["available"] as? String
						let available = Utils.isAvailable(avail!)
						
						let image_string = jObj["image"] as? String
						let image = Utils.stringToImageArray(image_string)//as NSData
						let ID = jObj["stylist_id"] as! String
						if ID.range(of: "-1") != nil{
							///is store stylist
						let sty = Stylist(id: ID, image: image, wait: 0)
							store.addStylist(sty)
						}else{
						let sty = Stylist(id: ID, name: name, phone: phone, image: image, wait: 0, available: available)
							store.addStylist(sty)
						}
						
						//MainViewController.updateStore(<#T##store: Store##Store#>, index: <#T##Int#>)dont thinl i need this
					}/////////////////////////end let...for for stylist info.................
					
					if let stores = json["stylist"] as? [[String: AnyObject]]{
						var index:Int = 0
						for jObj in stores{///////////////////////for loop
							let id = jObj["stylist_id"] as? String
							let wait = Int(jObj["wait"] as! String)
							var sty = store.stylist_array[index]
							sty.setWait(wait!)
							store.updateStylist(sty,index: index)
							index += 1
							
						}/////////////////////////end for
						
					}//end let
					//MainViewController.updateStore(store, index: MainViewController.selectedPosition)
					lf.stylistTableView.reloadData()
					service_request(store: store)
				}
			}catch {
				print("no json..err")			}
		}) 
		
		task.resume()
	}
	////////////////////////////////////Service Request
	
	static func service_request(store: Store)
	{
		var df = DateFormatter()//format date
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		var param:String="store_services="+("acbastoreservicesacba").sha1()
		param += "&date="+df.string(from: Date())
		param += "&store_id="+store.phone!
		
		let url:URL = URL(string: servicesURL)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler: {
			(
			data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			do{
				let json = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject]
				//var store = MainViewController.getCurrentStore()
				
				if let stores = json["store_services"] as? [[String: AnyObject]]{
					for jObj in stores{///////////////////////for loop
						let id = Int(jObj["id"] as! String)
						let name = jObj["name"] as! String
						let price = Double(jObj["price"] as! String)
						let duration = jObj["duration"] as! String
						let service = Service( id: id!, name: name, price: price!, duration: duration)
						store.addService(id!, service: service)
						
					}/////////////////////////end let...for for stylist info.................
					
					if let stores = json["reservations"] as? [[String: AnyObject]]{
				
						for jObj in stores{///////////////////////for loop
							
							let id = jObj["stylist_id"] as! String
							let st = jObj["start_time"] as! String
							let et = jObj["end_time"] as! String
							store.reservation.setDateTime(stylist_ID: id, start: st, end: et,store:store)
						}/////////////////////////end for
						
					}//end let
		
					//MainViewController.updateStore(store, index: MainViewController.selectedPosition)
					ReservationViewController.stylist_tv?.reloadData()
					ReservationViewController.service_tv?.reloadData()
					
				}
				
				
			}catch {
				print("no json..err")			}
		})
		
		task.resume()
	}
	
	/**
	POST request to login.php. Parses status response then stermines if the login was successfull or not
	*/
	
	static func login_request(_ lvc:LoginViewController,user:String,pass:String)
	{
		
		var param:String="code="+("acbaloginacba").sha1()+"&username="+user+"&password="+(pass).sha1()
		let url:URL = URL(string: loginURL)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler: {
			(
			data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			
	let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
			
			do{
				
				let jsonObject = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject]
				
				let response = jsonObject["status"] as! Array<AnyObject>
				
				if response == nil || response.count == 0{
					
					 OperationQueue.main.addOperation {
						lvc.error(msg:"Invalid username and password")
					}
					return
				}
				
				let obj = response[0] as! [String:AnyObject]
				if( obj["success"]! as! String == "true" ){
					let user = obj["login"] as! String
					if( user == "user" ){
					 OperationQueue.main.addOperation {	//call back to main thread
						lvc.loginSuccess()
						}
					
					}else{
						
							let store_id = obj["store_id"] as! CLong
						
							let stylist_id = obj["stylist_id"] as! String
						 OperationQueue.main.addOperation {	//call back to main thread
							lvc.stylistScreen(store_id:store_id, stylist_id:stylist_id)
						}
					}
				}else{
					//print("error in login")
						lvc.error()
				}
				
			}catch {
				print("no json..err")
				lvc.error(msg:"Network is down :( ...")
		}
			
	})
		
		task.resume()
		
	}
	static func stylistWebTaskAppointments(svc:StylistViewController, stylist_id:String, store_id:CLong)
	{
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let now = df.string(from: Date())
		
		let param:String="stylist="+("acbastylistlistacba").sha1()+"&store_id=\(store_id)&date=\(now)&stylist_id=\(stylist_id)&employee_activity=true"
		let url:URL = URL(string: stylistURL)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler: {
			(
			data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			
			let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
			
			do{
				
				let jsonObject = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject]
				if let stores = jsonObject["stylist"] as? [[String: AnyObject]]{
					for jObj in stores{///////////////////////for loop
						let fname = jObj["fname"] as? String
						let mname = jObj["mname"] as? String
						let lname = jObj["lname"] as? String
						let name = Utils.formatName(fname, mname: mname, lname: lname)
						
						let phone = jObj["phone"] as? String
						
						let avail = jObj["available"] as? String
						let available = Utils.isAvailable(avail!)
						
						let image_string = jObj["image"] as? String
						let image = Utils.stringToImageArray(image_string)//as NSData
						let ID = jObj["stylist_id"] as! String
						if ID.range(of: "-1") != nil{
							///is store stylist
							let sty = Stylist(id: ID, image: image, wait: 0)
							svc.setStylist(sty: sty)
						}else{
							let sty = Stylist(id: ID, name: name, phone: phone, image: image, wait: 0, available: available)
							svc.setStylist(sty: sty)
						}
						
						
					}//loop through stylist info...end for loop
				}
				var reservation = Reservation(svc.stylist!)
				if let stores = jsonObject["appointments"] as? [[String: AnyObject]]{
					let df = DateFormatter()
					df.dateFormat = "yyyy-MM-dd HH:mm:ss"
					for jObj in stores{///////////////////////for loop
						let start = jObj["start_time"] as? String
						let end = jObj["end_time"] as? String
						var cust_id = jObj["customer_id"] as? String
						var name = jObj["customer_name"] as? String
						var notes = jObj["notes"] as? String
						let service = jObj["service_name"] as? String
						var phone = jObj["phone"] as? String
						if phone == nil {
							phone = "N/A"
						}
						if notes == nil {
							notes = "N/A"
						}
						if name == nil{
							name = "N/A"
						}
						if cust_id == nil{
							cust_id = "N/A"
						}
						let cust = Customer(id:cust_id!,name:name!,phone:phone!, email:"")
						let ds = df.date(from: start!)
						let de = df.date(from: end!)
						let ts = TimeSet(start:ds!,end: de! )
						let rd = ReservationDetails(ts:ts,service_name:service!,cust:cust,notes:notes!)
						reservation.setDateTime(stylist: svc.stylist!, start: start!, end: end!, rd:rd)
						
					}//loop through stylist info...end for loop
					svc.setReservation(rs:reservation)
					StylistViewController.reservations = reservation
				}
				///////////////////end appointmenrs
								svc.displayToday()
			}catch {
				svc.error(msg:"Network is down :( ...")
				print("no json..err")
			}
			
		})
		
		task.resume()
		
	}	////////////end stylist get reservation appointments fro stylist activity
}
