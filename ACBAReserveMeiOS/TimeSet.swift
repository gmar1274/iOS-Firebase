//
//  Reservation.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/29/16.
//  Copyright © 2016 user. All rights reserved.
//
import Foundation
class TimeSet: NSObject{
	var lower_bound:Date
	var upper_bound:Date
	var delta_time:CLong//should be in seconds

	override init(){
		self.lower_bound = Date()
		self.upper_bound = Date()
		self.delta_time = 0
	}
	init(start:Date, end:Date){
		self.lower_bound = start
		self.upper_bound = end
		self.delta_time = CLong(lower_bound.timeIntervalSince(upper_bound)) //duration
		
	}
	init(lb_string:String, ub_string:String){//already reserved
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss" //change to Date object
		self.lower_bound = df.date(from: lb_string)!
		self.upper_bound = df.date(from: ub_string)!
		self.delta_time = CLong(upper_bound.timeIntervalSince(lower_bound))//should be seconds
		
	}
	//this is for a service with duration and reservation start time start
	init(start:Date, duration:CLong ) {
		self.lower_bound = start
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		self.upper_bound = self.lower_bound.addingTimeInterval(TimeInterval(duration))//should add seconds to date
		self.delta_time = duration
	}
	
	 func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? TimeSet {
			return self.display12HourFormat().hashValue == object.display12HourFormat().hashValue
		} else {
			return false
		}
	}
	
	func getLowerBoundFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "h:mm a"
		return df.string(from: self.lower_bound)
	}
	func getUpperBoundFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "h:mm a"
		return df.string(from: self.upper_bound)
	}
	func display12HourFormat() -> String{
		return self.getLowerBoundFormat()+"-"+self.getUpperBoundFormat()
	}
	//Should give what i want if not need to change the date extensions
	func isSubSet(ts:TimeSet) -> Bool {
		return self.upper_bound.isBeforeDate(dateToCompare: ts.upper_bound) && self.lower_bound.isAfterDate(dateToCompare: ts.lower_bound) && self.lower_bound.isSameDay(dateToCompare: ts.lower_bound)
	}
	
	func isDisjoint(ts:TimeSet) -> Bool{
		return isLowerBoundDisjoint(ts: ts) || isUpperBoundDisjoint(ts: ts)
	}
	func isLowerBoundDisjoint(ts:TimeSet) -> Bool {
		return self.lower_bound.isBeforeDate(dateToCompare: ts.lower_bound) && self.upper_bound.isBeforeDate(dateToCompare: ts.lower_bound) && self.lower_bound.isSameDay(dateToCompare: ts.lower_bound)
	}
	func isUpperBoundDisjoint(ts:TimeSet) -> Bool {
		return self.lower_bound.isAfterDate(dateToCompare: ts.upper_bound) && self.upper_bound.isAfterDate(dateToCompare: ts.upper_bound) && self.lower_bound.isSameDay(dateToCompare: ts.upper_bound)
	}
	func displayFull12HourTimeRangeFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "MMM/dd/yyyy h:mm a"
		return df.string(from: self.lower_bound)+"-"+df.string(from: self.upper_bound)
	}
	override public var description: String { return self.display12HourFormat()}
	
	override var hashValue: Int{
		get{
			return self.displayFull12HourTimeRangeFormat().hash
		}
	}
}
func ==(lhs: TimeSet, rhs: TimeSet) -> Bool {
	return lhs.display12HourFormat() == rhs.display12HourFormat()
}


