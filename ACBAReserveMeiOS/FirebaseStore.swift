//
//  FirebaseStore.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/4/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Firebase
import MapKit
import AddressBook

class FirebaseStore : FIRDataObject, MKAnnotation{
	//public var coordinate: CLLocationCoordinate2D

	var address:String?
	var card_id:String?
	var citystate:String?
	var close_time:String?
	var email:String?
	var google_place_id:String?
	var location:LatLng?
	var miles_away:CDouble?
	var name:String?
	var open_time:String?
	var password:String?
	var phone:String?
	var reservation_calendar_price:CDouble?
	var store_number:CLong?
	var subscription_id:String?
	var ticket_price:CDouble?
	var current_ticket:CLong = 0
	 /*init() {
		super.init(snapshot: snap)
		self.address=""
		self.card_id=""
		self.citystate=""
		self.close_time=""
		self.email=""
		self.google_place_id=""
		self.location=LatLng(lat: 0, lon: 0)
		self.miles_away=0;
		self.name=""
		self.open_time=""
		self.password=""
		self.phone=""
		self.reservation_calendar_price=0;
		self.store_number=0
		self.subscription_id=""
		self.ticket_price=0
	}*/
	
	required init(snapshot: FIRDataSnapshot) {
		super.init(snapshot: snapshot)
		//self.coordinate = CLLocation(latitude: 0, longitude: 0).coordinate
		//fatalError("init(snapshot:) has not been implemented")
	}
	
	func operatingHours() -> String {
		let date_formatter = DateFormatter()
		date_formatter.dateFormat = "HH:mm:ss" //change to date
		let open_date = date_formatter.date(from: self.open_time!)
		let close_date = date_formatter.date(from: self.close_time!)
		let date_formatter_12hr = DateFormatter()
		date_formatter_12hr.dateFormat = "h:mm a"
		return date_formatter_12hr.string(from: open_date!) + "-" + date_formatter_12hr.string(from: close_date!)
	}
	func setLocation(latlng:LatLng){
		self.title=name!
		self.location = latlng
		self.coordinate = CLLocation(latitude:(self.location?.latitude)!,longitude:(self.location?.longitude)!).coordinate
	}
	// annotation callout info button opens this mapItem in Maps app
	func mapItem() -> MKMapItem {
		self.title = self.name!
		self.subtitle = "custom sub title..."
  let addressDictionary = [String(kABPersonAddressStreetKey): "SubTitle"]
  let placemark = MKPlacemark(coordinate: self.coordinate , addressDictionary: addressDictionary as AnyObject as! [String : AnyObject])
		
  let mapItem = MKMapItem(placemark: placemark)
  mapItem.name = self.name
		
  return mapItem
	}

	
}
