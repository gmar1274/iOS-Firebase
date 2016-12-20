//
//  Store.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/21/16.
//  Copyright © 2016 user. All rights reserved.
//
import MapKit
import AddressBook

class Store: NSObject, MKAnnotation {
	let title: String?
	let locationName: String
	let coordinate: CLLocationCoordinate2D//lat long
	let subtitle: String?
 
	var name:String?
	var id:String?
	var address:String?
	var zip:String?
	var google_id:String?
	var city:String?
	var state:String?
	var open_hours:String?
	var close_hours:String?
	var phone:String?
	var ticket_price:Double?
	var reservation_price:Double?
	var distance:Double?
	
	init(title: String, locationName: String, coordinate:CLLocationCoordinate2D) {
		self.title = title
		self.locationName = locationName
		self.coordinate = coordinate
		self.subtitle=locationName
		
		super.init()
	}
	func setVariables(name:String,id:String,address:String,city:String,state:String,zip:String,ticket_price:Double,rservation_price:Double,open:String,close:String,distance:Double){
		self.name=name
		self.id=id
		self.address=address
		self.city=city
		self.state=state
		self.zip=zip
		self.open_hours=open
		self.close_hours=close
		self.distance=distance
		
		
	}

	// annotation callout info button opens this mapItem in Maps app
	func mapItem() -> MKMapItem {
  let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
  let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary as! AnyObject as! [String : AnyObject])
		
  let mapItem = MKMapItem(placemark: placemark)
  mapItem.name = self.title
		
  return mapItem
	}
}