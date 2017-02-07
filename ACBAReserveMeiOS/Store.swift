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
	let locationName: String?
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
	///////////services offered by this store
	var	service_hm:[Int:Service]! // ID -> Service
	var stylist_array:[Stylist] //[String:Stylist] // String_ID -> Service
	var stylist_hm: [String:Stylist]
	var reservation:Reservation
	init(title: String?, locationName: String?, coordinate:CLLocationCoordinate2D) {
		self.title = title
		self.locationName = locationName
		self.coordinate = coordinate
		self.subtitle=locationName
		self.service_hm = [:]//empty hashmap
		self.stylist_array = [Stylist]() // empty stylist arraylist
		self.reservation = Reservation()
		self.stylist_hm = [:]
		super.init()
	}
	//add service to hash map
	func addService(_ id:Int , service:Service){
		self.service_hm[id] = service
	}
	
	func setVariables(_ name:String?,id:String?,address:String?,city:String?,state:String?,zip:String?,ticket_price:Double?,reservation_price:Double?,open:String?,close:String?,distance:Double? , phone:String?){
		self.name=name
		self.id=id
		self.address=address
		self.city=city
		self.state=state
		self.zip=zip
		self.open_hours=open
		self.close_hours=close
		self.distance=distance
		self.phone=phone
		self.ticket_price = ticket_price
		self.reservation_price = reservation_price
		
	}
	func getServiceArray() -> [Service]{
		return [Service](service_hm.values)
	}
	func getStylistsForAppointments() -> [Stylist]{
		if(stylist_array == nil || stylist_array.count == 0){return []}
		var arr = stylist_array
		arr.remove(at: 0) //creates alot of new arrays so for less than 10 we should be fine.. until update 
		//for optimization..
		return arr
	}
	func operatingHours() -> String {
		let date_formatter = DateFormatter()
		date_formatter.dateFormat = "HH:mm:ss" //change to date
		let open_date = date_formatter.date(from: self.open_hours!)
		let close_date = date_formatter.date(from: self.close_hours!)
		let date_formatter_12hr = DateFormatter()
		date_formatter_12hr.dateFormat = "h:mm a"
		return date_formatter_12hr.string(from: open_date!) + "-" + date_formatter_12hr.string(from: close_date!)
	}
	func updateStylist(_ sty:Stylist, index:Int){
		self.stylist_array.remove(at: index)
		self.stylist_array.insert(sty, at: index)
	}
	func getAddressFormatted() -> String {
		var address = ""
		if self.address != nil {
			address = self.address!
		}
		if self.city != nil {
			address += " "+self.city!
		}
		if self.state != nil{
			address += " , "+self.state!
		}
		if self.zip != nil {
			address += " "+self.zip!
		}
		return address
	}
	
	func addStylist(_ stylist:Stylist){
		self.stylist_hm[stylist.ID] = stylist
		self.stylist_array.append(stylist)
	}

	// annotation callout info button opens this mapItem in Maps app
	func mapItem() -> MKMapItem {
  let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
  let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary as AnyObject as! [String : AnyObject])
		
  let mapItem = MKMapItem(placemark: placemark)
  mapItem.name = self.title
		
  return mapItem
	}
	
}
