//
//  Utils.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/22/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Utils{
	
	
	static func formatName(_ fname:String?,mname:String?, lname:String?) -> String {
		if  mname != nil && mname?.characters.count > 0{
			return fname!+" "+mname!+" "+lname!
		}
		return fname!+" "+lname!
	}
	static func isAvailable(_ avail:String) -> Bool{
		return avail.range(of: "1") != nil
	}
	static func stringToImageArray(_ fileBase64:String?) -> Data{
		if  fileBase64 != nil {
			return Data(base64Encoded: fileBase64!, options: [])!
		} //else missing
		return Data()
	}
	static func callNumber(_ phoneNumber:String) {
			 let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)")!
             UIApplication.shared.openURL(phoneCallURL)
		
	}//////////end call method
	static func getTodaysTimeSetList(day:Date, appointments:[Date:Date] ) -> [TimeSet]{
		
		var list:[Date] = Array<Date>(appointments.keys) //keys
		list = list.sorted()//sorted b dates ASC
		var taken_list:[TimeSet] = []
		for date in list{
			
			if !date.isSameDay(dateToCompare: day) && date.isAfterDate(dateToCompare: day){ //after no need to continue
				return taken_list
			}
			if !date.isSameDay(dateToCompare: day){
				continue
			}
			let date_end = appointments[date] //get the value for key date
			let ts = TimeSet(start: date, end: date_end!)
			taken_list.append(ts)//add taken time range
		}
		
		return taken_list
	}
	static func getTimeToSeconds(duration:String) -> CLong{
		let arr = getSplicedArrayOfTime(time: duration)
		let hour = Int(arr[0]) * 60 * 60 //hour to secs
		let min = Int(arr[1]) * 60 // min to seconds
		return hour + min
	}
	static func getSplicedArrayOfTime(time:String) -> [Int] {
		let arr = time.characters.split(separator: ":").map(String.init)
		let hour:Int = Int(arr[0])!
		var min:Int = 0
		if arr.count == 2 {
			min = Int(arr[1])!
		}
		return [hour,min]
	}
	//sets the miles_away property if in bounds
	static func isInRadiusSearch(user_loc : CLLocation, store:FirebaseStore, miles:CDouble) -> Bool{
		let store_loc = CLLocation(latitude: CLLocationDegrees((store.location?.latitude)!), longitude: CLLocationDegrees((store.location?.longitude)!))
		let dist = (user_loc.distance(from: store_loc) )/1609.344//convert meters to miles by dividing
		if dist <= miles {
			store.miles_away = NSNumber(value:dist)
			return true
		}
		return false
	}
	static func generateID(username:String) -> String{
		return String(username.hashValue)
	}
	static func formatPhone(phone:String) -> String{
		if phone.characters.count == 0 || phone.characters.count == 3{
			return "N/A"
		}
		var phonee = NSMutableString()
		phonee.append(phone as String)
		if(phonee.description.characters.count==11){
			phonee.insert("+", at: 0)
			phonee.insert("(", at: 2)
			phonee.insert(")", at: 6)
			phonee.insert("-", at: 10)
			
			return phonee.description
		}else{
			phonee.insert("(", at: 0)
			phonee.insert(")", at: 4)
			phonee.insert("-", at: 8)
		return "+1"+phonee.description
		}
	}
	
}//end utils class
