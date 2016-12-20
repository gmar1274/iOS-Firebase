//
//  StoreModel.swift
//  ReserveMe
//
//  Created by user on 8/16/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation

protocol StoreModelProtocal: class {
	func itemsDownloaded(items: NSArray)
}


class StoreModel: NSObject, NSURLSessionDataDelegate {
	
	//properties
	
	weak var delegate: StoreModelProtocal!
	
	var data : NSMutableData = NSMutableData()
	
	//let urlPath: String = "http://www.acbasoftware.com/store.php"
	let web="http://www.acbasoftware.com/store.php"
	
	func downloadItems() {
		
		//let url: NSURL = NSURL(string: urlPath)!
		//var session: NSURLSession!
		///let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		
		
		//session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		
		//let task = session.dataTaskWithURL(url)
		///
		//task.resume()
		/////////////////////////////////
		
		
		let request = NSMutableURLRequest(URL: NSURL(string: web)!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		
		let code=("acbastorelistacba").sha1()
		let postString = "&store="+code
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
	/*
	func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
		self.data.appendData(data);
		
	}
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		if error != nil {
			print("Failed to download data")
		}else {
			print("Data downloaded")
			self.parseJSON()
		}
		
	}*/
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
		let locations: NSMutableArray = NSMutableArray()
		do {
			
			// Parse the JSON
			let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
			
			let value = jsonDictionary["store"] as! NSArray
			for(var i=0; i<value.count; ++i){
				let name:String=(value[i]["Store"] as? String)!
				let address:String=(value[i]["Address"] as? String)!
				let citystate:String=(value[i]["CityState"] as? String)!
				let id:String=(value[i]["id"] as? String)!
				
				let store:Store=Store(name:name,address:address,citystate:citystate,id:Int(id)!)
				//self.store_map[Int(id)!]=store
				//print(value[i])
				//print(value[i]["id"])
				locations.addObject(store)
			}
			
		} catch {
			//error
		}			/////
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
			self.delegate.itemsDownloaded(locations)
			
		})
	}
	
}