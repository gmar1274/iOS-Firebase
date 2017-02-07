//
//  Stylist.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/21/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation


func == (lhs: Stylist, rhs: Stylist) -> Bool {
	return lhs.ID == rhs.ID
}

class Stylist: Hashable{
	
	
	var hashValue: Int{
		get{
			return ID.hashValue
		}
	}
	let name:String
	let phone:String
	let isAvailble:Bool
	let imageArray:Data
	var wait:Int
	let ID:String
	var haircut_time:Int //time it takes stylist to give standard haircut
	init(id:String,image:Data, wait:Int){
			name = "No Preference"
		    phone = ""
			isAvailble = true
			imageArray = image
			self.wait = wait
			self.ID = id
		    self.haircut_time = 45
	}
	init(id:String, name:String,phone:String?, image:Data, wait:Int, available:Bool){
		self.name=name
		self.ID=id
		if phone != nil{
		self.phone=phone!
		}else{
			self.phone = ""
		}
		self.imageArray=image
		self.wait=wait
		self.isAvailble=available
		self.haircut_time = 45//defualt
	}
	func setHaircutWeight(_ weight:Int){
		self.haircut_time = weight
	}
	func setWait(_ wait:Int){
		self.wait=wait
	}
	///Total wait in mins
	func calculateWait() -> Int{
		return wait * haircut_time
	}
	func getReadyByDateFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "h:mm a"
		let dateAfterMin = Date.init(timeIntervalSinceNow: (Double(calculateWait()) * 60.0))
		return df.string(from: dateAfterMin)
	}
	
	func getApproxWait() -> String {
		/**let formatter = NSNumberFormatter()
		formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
		formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
		formatter.maximumFractionDigits = 0*/
		let total_min = haircut_time * wait
		let hour = total_min / 60
		let min = total_min % 60
		if(hour==0) {
			return String(min) + " mins"
		}
		return String(hour) + " hrs "+String(min) + " mins"
	}
}
