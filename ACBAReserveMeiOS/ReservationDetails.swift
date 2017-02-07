//
//  ReservationDetails.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/31/16.
//  Copyright © 2016 user. All rights reserved.
//
import Foundation
class ReservationDetails{
	
	//var datetime:NSDate
	var service_name:String
	var notes:String
	var customer:Customer
	var timeSet:TimeSet
	var datetime: Date
	init (ts: TimeSet , service_name: String , cust :Customer, notes :String){
		self.service_name = service_name
		self.notes = notes
		self.customer = cust
		self.timeSet = ts
		self.datetime = ts.lower_bound
	}
	init (){
		self.service_name = "N/A"
		self.notes = "N/A"
		self.timeSet = TimeSet()
		self.datetime = Date()
		self.customer = Customer()
	}
}
