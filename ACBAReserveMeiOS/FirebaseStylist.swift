//
//  FirebaseStylist.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/6/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Firebase
class FirebaseStylist: FIRDataObject{
	var name:String?
	var available:Bool?
	var fname:String?
	var mname:String?
	var lname:String?
	var phone:String?
	var wait:Int?
	var id:String?
	var store_number:CLong?
	var haircut_time:Int=40//in mins 40 by default
	
	required init(snapshot: FIRDataSnapshot) {
		super.init(snapshot: snapshot)
	}
	func getApproxWait(service_time_mins:CDouble) -> String {
		
		if wait == nil{
			wait = 0
		}		/**let formatter = NSNumberFormatter()
		formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
		formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
		formatter.maximumFractionDigits = 0*/
		let total_min = service_time_mins * CDouble(wait!)
		let hour = total_min / 60
		let min = Int(total_min) % 60
		if(hour==0) {
			return String(min) + " mins"
		}
		return String(hour) + " hrs "+String(min) + " mins"
	}
	func getApproxWait() -> String {//default time otherwise when loading friebase db will be updated
		/**let formatter = NSNumberFormatter()
		formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
		formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
		formatter.maximumFractionDigits = 0*/
		if wait == nil{
			wait = 0
		}
		let total_min = haircut_time * wait!
		let hour = total_min / 60
		let min = total_min % 60
		if(hour==0) {
			return String(min) + " mins"
		}
		return String(hour) + " hrs "+String(min) + " mins"
	}
	///Total wait in mins
	func calculateWait() -> Int{
		return wait! * haircut_time
	}
	func getReadyByDateFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "h:mm a"
		let dateAfterMin = Date.init(timeIntervalSinceNow: (Double(calculateWait()) * 60.0))
		return df.string(from: dateAfterMin)
	}
	
	 func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? FirebaseStylist {
			return self.id! == object.id!
		} else {
			return false
		}
	}
	
	override var hash: Int {
		return self.id!.hashValue
	}
	
	
	
}
