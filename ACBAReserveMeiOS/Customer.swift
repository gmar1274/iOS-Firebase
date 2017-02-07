//
//  Customer.swift
//  ACBAReserveMeiOS
//  Created by user on 12/31/16.
//  Copyright © 2016 user. All rights reserved.
class Customer{
	var name:String
	var id:String
	var phone:String
	var email:String
	init(id:String, name:String, phone:String, email:String){
		self.name = name
		self.id = id
		self.phone = phone
		self.email = email
	}
	init(){
		self.name = "N/A"
		self.id = "N/A"
		self.phone = "N/A"
		self.email = "N/A"
		
	}
}
