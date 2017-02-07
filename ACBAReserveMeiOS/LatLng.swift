//
//  Location.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/4/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
class LatLng{
	
	var latitude:CDouble
	var longitude:CDouble
	init(lat:CDouble,lon:CDouble) {
		self.latitude = lat
		self.longitude = lon
	}
	
	func getLatitude() -> CDouble {
		return self.latitude
	}
	func getLongitude() -> CDouble {
		return self.longitude
	}
}
