//
//  Store.swift
//  ReserveMe
//
//  Created by user on 8/15/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
class Store {
	var name: String
	var address: String
	var citystate: String
	var id:Int
	var city:String
	var state:String
	
	init (name: String, address:String,citystate:String ,id: Int) {
		self.name=name;
		self.address=address
		self.citystate=citystate
		self.id=id
		self.city=""
		self.state=""
		
	}
	func setCity(city:String) -> Void {
		self.city=city
	}
	func setState(state:String) -> Void {
		self.state=state
	}
	func getName() -> String {
		return self.name
	}
	func getAddress() -> String {
		return self.address
	}
	func getCityState() -> String {
		return self.citystate
	}
	func getID() -> Int {
		return self.id
	}
}