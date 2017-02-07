//
//  Services.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/21/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation

class Service {
	var name:String
	var ID:Int
	var price:Double
	var duration:String
	init (){
		self.name=""
		self.ID = -1
		self.price=0
		self.duration=""
	}
	init (id:Int, name:String, price:Double, duration:String){
		self.ID = id
		self.name = name
		self.price = price
		self.duration = duration
	}
	
	func getDurationFormatted() -> String {
		let array = duration.components(separatedBy: ":")//get array of 00:00:00
		let hours = Int(array[0])!
		let mins = Int(array[1])!
		if(hours==0){
		return String(describing: mins)+" mins"
		}
		return String(describing: hours)+" hrs "+String(describing: mins)+" mins"
	}
	func getPriceFormatted() -> String {
		let nf=NumberFormatter()
		nf.numberStyle = .currency
		let price_n = self.price as NSNumber
		return nf.string(from: price_n)!
	}
	func getDurationInSeconds() -> CLong {
		return Utils.getTimeToSeconds(duration:self.duration)
	}
	
}
