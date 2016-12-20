//
//  StylistModel.swift
//  ReserveMe
//
//  Created by user on 8/16/16.
//  Copyright © 2016 user. All rights reserved.
//
import Foundation

protocol StylistModelProtocal: class {
	func itemsDownloaded(items: NSArray)
}


class StylistModel: NSObject, NSURLSessionDataDelegate {
	
	//properties
	
	weak var delegate: StylistModelProtocal!
	
	var data : NSMutableData = NSMutableData()
	
	//let urlPath: String = "http://www.acbasoftware.com/store.php"
	let web="http://www.acbasoftware.com/stylist.php"
	
	func downloadItems(storeID:Int) {
		
		let request = NSMutableURLRequest(URL: NSURL(string: web)!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		
		let sty=("acbastylistlistacba").sha1()
		let date = NSDate()
		let sdf = NSDateFormatter()
		sdf.timeZone = NSTimeZone(name: "UTC")
		sdf.dateFormat = "yyyy-MM-dd"
		//let date = NSDate()
		//print("Date: "+sdf.stringFromDate(date))
		//print("ID: "+String(storeID))
		let postString = "stylist="+sty+"&store_id="+String(storeID)+"&date="+String(sdf.stringFromDate(date))
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			guard error == nil && data != nil else {
				//self.showError()// check for fundamental networking error
				return
			}
			if let HTTPResponse = response as? NSHTTPURLResponse {
				let statusCode = HTTPResponse.statusCode
				
				//let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
				//print(responseString)//server response
				if (statusCode == 200) {
					self.data.appendData(data!)
					//print("GOOD CONNECTION")///good connection
					self.parseJSON()
				}else{
					//self.showError()
				}
			}
			
			
		}
		task.resume()
		
		
		
		
	}
	func parseJSON() {
		//print("PARSING")
		/*
		var jsonResult: NSMutableArray = NSMutableArray()
		
		do{
		jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
		
		} catch let error as NSError {
		print(error)
		
		}
		
		var jsonElement: NSDictionary = NSDictionary()
		let locations: NSMutableArray = NSMutableArray()
		
		for(var i = 0; i < jsonResult.count; ++i)
		{
		
		jsonElement = jsonResult[i] as! NSDictionary
		
		
		}*/
		let locations: NSMutableArray = NSMutableArray()//global array list im saving to return
		do {
			
			// Parse the JSON
			let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
			//print(jsonDictionary)
			let value = jsonDictionary["stylist"] as! NSArray
			let stylist_names = jsonDictionary["stylist_names"] as! NSArray
			
			
			var stylist_dict = Dictionary<Int,Stylist>()
			
			for(var i=0; i<value.count; ++i){
				let id:String=(value[i]["stylist_id"] as? String)!
				let wait:String=(value[i]["wait"] as? String)!
				
				let stylist:Stylist=Stylist(id:Int(id)!,wait:Int(wait)!)
				//print("ID:\(id) wait: \(wait)")
				stylist_dict[Int(id)!]=stylist
				
				//locations.addObject(stylist)
			}
			if let val = stylist_dict[-1] {
			
				val.setFname("Store No Preference")
				stylist_dict[-1]=val
				locations.addObject(val)
				
			}
			for(var i=0; i<stylist_names.count; ++i){
				let fname:String=(stylist_names[i]["fname"] as? String)!
				let mname:String=(stylist_names[i]["mname"] as? String)!
				let lname:String=(stylist_names[i]["lname"] as? String)!
				let id:String=(stylist_names[i]["stylist_id"] as? String)!
				let a=(stylist_names[i]["available"] as? String)!
				let imageURL:String=(stylist_names[i]["image"] as? String)!
				let available=Int(a)
				//let available=Bool(here)
				if var stylist=stylist_dict[Int(id)!]{
				stylist.setFname(fname)
				stylist.setMname(mname)
				stylist.setLname(lname)
				stylist.setAvailable(available!)
				stylist.setImageURL(imageURL)
				stylist_dict[Int(id)!]=stylist
					locations.addObject(stylist)
				}else{
					var stylist=Stylist(id: Int(id)!,wait: 0)
					stylist.setFname(fname)
					stylist.setMname(mname)
					stylist.setLname(lname)
					stylist.setAvailable(available!)
					stylist.setImageURL(imageURL)
					locations.addObject(stylist)
				}
				
				
			}
			
		} catch {
			print("ERRROROROROR")//error
		}			/////
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
			self.delegate.itemsDownloaded(locations)
			
		})
	}
	
}