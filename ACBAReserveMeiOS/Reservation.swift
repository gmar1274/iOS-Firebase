//
//  Reservation.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/30/16.
//  Copyright © 2016 user. All rights reserved.
//
import Foundation

class Reservation{
	var time_range_details: [TimeSet:ReservationDetails]
	var reservation_hm: [Stylist:[Date:Date]]
	var days_reserved: [String:[TimeSet:ReservationDetails]]
	
	var dayArray:Array<String> = []
	init(){
		self.time_range_details = [:]
		self.reservation_hm = [:]
		self.days_reserved = [:]
		self.dayArray = []
	}
	init(sty:[Stylist]){
		self.time_range_details = [:]
		self.days_reserved = [:]
		self.reservation_hm = [:]
		self.dayArray = []
		initHM(sty: sty)
		
	}
	/**Usage for the stylsit app.. Only need for one stylisy*/
	init(_ sty:Stylist){
		self.time_range_details = [:]
		self.reservation_hm = [:]
		self.days_reserved = [:]
		self.reservation_hm[sty] = [:]//init the reservations only for stylist sty
		self.dayArray = []
	}
	func initHM(sty:[Stylist]){//add the stylist for each in list and add a empty value
		for s in sty {
		
			self.reservation_hm[s] = [:]
			
		}
	}
	func getReservationDetails(ts:TimeSet) -> ReservationDetails{
		if(self.time_range_details == nil || self.time_range_details[ts] == nil){
			return ReservationDetails()
		}
		return self.time_range_details[ts]!
	}
	/**
	This function takes the string the represention of a stylist and the datetime start and end. And
	adds to the hashmap
	*/
	func setDateTime(stylist_ID:String, start:String, end:String, store:Store) {
		if self.reservation_hm.count == 0{
			initHM(sty: store.getStylistsForAppointments())
			
		}
	
		let sty = store.stylist_hm[stylist_ID]!
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		df.timeZone = TimeZone.ReferenceType.local
		let start_date = df.date(from: start)!
		let end_date = df.date(from: end)!
		var hm = self.reservation_hm[sty]! //get hm of stylist
		hm[start_date] = end_date    //add the dates
		self.reservation_hm[sty] = hm //update the apppointments
	}
	/**Usage for stylist app...*/
	func setDateTime(stylist:Stylist, start:String, end:String, rd: ReservationDetails) {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		df.timeZone = TimeZone.ReferenceType.local
		let start_date = df.date(from: start)!
		let end_date = df.date(from: end)!
		var hm = self.reservation_hm[stylist]! //get hm of stylist
		hm[start_date] = end_date    //add the dates
		self.reservation_hm[stylist] = hm //update the apppointments
		let ts = TimeSet(start:df.date(from:start)!, end: df.date(from:end)!)
		self.time_range_details[ts] = rd
		let sdf = DateFormatter()
		sdf.dateFormat = "MMM/dd/yyyy"
		let date = sdf.string(from: start_date)
		let days_hm:[TimeSet:ReservationDetails]? = self.days_reserved[date]
		//print("SAVING \(date)")
		if days_hm == nil{
			let thm:[TimeSet:ReservationDetails] = [ts:rd]
			self.days_reserved[date] = thm
			self.dayArray.append(date)
		}else{
			self.days_reserved[date] = [ts:rd]
			self.dayArray.append(date)
		}
		
	}
	func getTimeSetArrayForDate(date:String) -> [TimeSet]{//used for upcoming dates
		//print("DATE:: \(date)")
		let val = self.days_reserved[date] //dictionary oft timesets
		var key:[TimeSet] = Array<TimeSet> (val!.keys)//keys
		key = key.sorted(by: {$0.lower_bound.isBeforeDate(dateToCompare: $1.lower_bound) })//sort bytime
		return key
	}
	/*Get a sorted list of the selected reservations in ASC order
	*/
	func getAppointments(sty:Stylist, day:Date) -> [TimeSet] {
		if self.reservation_hm[sty] == nil || self.reservation_hm.count == 0 {
			
			return []
		}
		
		return Utils.getTodaysTimeSetList(day: day, appointments: self.reservation_hm[sty]!)
	}
	
}
