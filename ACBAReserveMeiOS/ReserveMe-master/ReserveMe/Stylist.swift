//
//  Stylist.swift
//  ReserveMe
//
//  Created by user on 8/16/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
class  Stylist  {
	var id:Int
	var wait:Int
	var fname:String
	var mname:String
	var lname:String
	var available:Int
	var reserveTime:NSDate
	var imageURL:String
	init(id:Int,wait:Int){
		self.id=id
		self.wait=wait
		self.fname=""
		self.mname=""
		self.lname=""
		self.available=0
		reserveTime=NSDate()
		imageURL="pictures/no_image.jpg"
	}
	func getImageURL() -> String {
		return self.imageURL
	}
	func setImageURL(url:String) {
		self.imageURL=url
	}
	func getReserveTime() -> String {
		let sdf = NSDateFormatter()
		sdf.dateStyle = NSDateFormatterStyle.LongStyle
		sdf.timeStyle = .ShortStyle
		return sdf.stringFromDate(reserveTime)
	}
	func approxWait(people:Int)->String{
		reserveTime = NSDate()
		
		let guess=people*30//30 min per person
		let hours=guess/60
		let mins=guess%60
		var date  = NSDate()
		let hour_to_min = (hours * (60) ) + mins//total mins
		reserveTime=date.dateByAddingTimeInterval( Double(hour_to_min) * 60.0)//total mins  multiplied by seconds
		
		if(hours<=0){
			
			return String(mins)+" mins"
		}
		return String(hours)+" hrs "+String(mins)+" mins"
	}
	
	func setAvailable(available:Int)  {
		self.available=available
	}
	func isAvailable() -> Bool {
		return self.available==1
	}
	func getID() -> Int {
		return id
	}
	func getWait() -> Int {
		return wait
	}
	func setFname(fname:String){
		self.fname=fname
	}
	func setMname(mname:String) {
		self.mname=mname
	}
	func setLname(lname:String) {
		self.lname=lname
	}
	func getName() -> String {
		var name:String
		if(self.mname.characters.count<=0)
		{return fname+" "+lname}else{
			return fname+" "+mname+" "+lname
		}
	}
}
