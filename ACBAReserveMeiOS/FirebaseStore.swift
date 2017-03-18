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
	var miles_away:NSNumber?
	var name:String?
	var open_time:String?
	var password:String?
	var phone:String?
	var reservation_calendar_price:NSNumber?
	var store_number:NSNumber?
	var subscription_id:String?
	var ticket_price:NSNumber?
	var current_ticket:NSNumber = 0
	var period:[Any]?
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
		
		self.title = self.name
		self.subtitle = ""
		
	}
	
	func setLocation(latlng:LatLng){
		self.title=name!
		self.location = latlng
		self.coordinate = CLLocation(latitude:CLLocationDegrees((self.location?.latitude)!),longitude:CLLocationDegrees((self.location?.longitude)!)).coordinate
	}
	// annotation callout info button opens this mapItem in Maps app
	func mapItem() -> MKMapItem {
		let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
  let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary as AnyObject as! [String : AnyObject])
		
  let mapItem = MKMapItem(placemark: placemark)
  mapItem.name = self.name!
		
  return mapItem
	}
	// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
	func getDayOfWeek()->Int {
		let formatter  = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let todayDate = Date()
		let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
		let myComponents = myCalendar.components(.weekday, from: todayDate)
		let weekDay = myComponents.weekday
		return (weekDay! - 2) % 7 // this now returns 0 - 6 as 0==monday ... 6== sunday
	}
	func getOperationalHours() -> String{
		let i = self.getDayOfWeek()
		//print("Day: \(i)")
		let hours = self.period?[i]
		return hours as! String
	}
	
}
