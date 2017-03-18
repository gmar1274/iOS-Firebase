//
//  Location.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/4/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
class LatLng{
	
	var latitude:NSNumber
	var longitude:NSNumber
	init(lat:CDouble,lon:CDouble) {
		self.latitude = NSNumber(value: lat)
		self.longitude = NSNumber(value: lon)
	}
	
	func getLatitude() -> CDouble {
		return self.latitude.doubleValue
	}
	func getLongitude() -> CDouble {
		return self.longitude.doubleValue
	}
	public var description: String { return "{\(self.latitude), \(self.longitude)} " }
}
