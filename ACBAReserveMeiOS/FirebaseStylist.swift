//
//  FirebaseStylist.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/6/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Firebase
class FirebaseStylist: NSObject{
	var name:String?
	var available:NSNumber?
	var fname:String?
	var mname:String?
	var lname:String?
	var phone:String?
	var wait:NSNumber?
	var id:String?
	var store_number:NSNumber?
	var haircut_time:NSNumber=35//in mins 35 by default
	var pseudo_wait:NSNumber = 0
	required init(snapshot: FIRDataSnapshot) {
		super.init()
		
		guard let dict = snapshot.value as? [String:AnyObject] else{
			return
		}
		
		for key in dict.keys{
			
			if responds(to: Selector(key)){
				setValue(dict[key] , forKey: key)
			}else{
				
				print("Key: \(key) Value: \(dict[key]) not found..\n")
			}
			
		}
		
		
		//super.init(snapshot: snapshot)
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
		let total_min = CLong(self.predictWait())
		let hour = total_min / 60
		let min = total_min % 60
		if(hour==0) {
			return String(min) + " mins"
		}
		return String(hour) + " hrs "+String(min) + " mins"
	}
	///Total wait in mins
	func calculateWait() -> Int{
		return NSNumber(value: (wait?.doubleValue)! * haircut_time.doubleValue).intValue
	}
	func getReadyByDateFormat() -> String {
		let df = DateFormatter()
		df.dateFormat = "h:mm a"
		let dateAfterMin = Date.init(timeIntervalSinceNow: (Double(self.predictWait()) * 60.0))
		return df.string(from: dateAfterMin)
	}
	
	 func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? FirebaseStylist {
			return self.id! == object.id!
		} else {
			return false
		}
	}
	func predictWait() -> CDouble{
		return CDouble(self.pseudo_wait.doubleValue * self.haircut_time.doubleValue)
	}
	
	override var hash: Int {
		return self.id!.hashValue
	}
	
	
	
}
