//
//  Ticket.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/8/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Firebase
class FirebaseTicket: NSObject {
	
	var unique_id:CLong
	var ticket_number:String
	var name:String
	var phone:String
	var email:String
	var stylist:String
	var stylist_id:String
	var readyBy:String?
	
	init(snapshot: FIRDataSnapshot){
		self.unique_id = -1
		self.name = "N/A"
		self.stylist = "N/A"
		self.stylist_id = "N/A"
		self.phone = "N/A"
		self.email = "N/A"
		self.ticket_number = "1"
		super.init()		
		for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? []{
			if responds(to: Selector(child.key)){
				setValue(child.value, forKey: child.key)
			}
		}
		
	}
	init(unique_ticket:CLong, sty:FirebaseStylist) {
		self.unique_id = unique_ticket
		self.name = "N/A"
		self.stylist = sty.name!
		self.stylist_id = sty.id!
		self.phone = ""
		self.email = ""
		self.ticket_number = "-1"//some error bug somewhere if this doesnt get updated
	}
	func getDictionaryFormat() -> [String:AnyObject]{
		var dic: Dictionary<String,AnyObject> = [:]
		let mo = Mirror(reflecting: self)
		for (index, attr) in mo.children.enumerated(){
			if let property_name = attr.label as String! {
				dic[property_name] = attr.value as AnyObject!
			}
		}
		return dic
	}
	override func isEqual(_ object: Any?) -> Bool {
		let o = object as! FirebaseTicket
		return self.unique_id == o.unique_id
	}

/*static func < (lhs: FirebaseTicket, rhs: FirebaseTicket) -> Bool {
	return lhs.unique_id < rhs.unique_id
	}
	static func <= (lhs: FirebaseTicket, rhs: FirebaseTicket) -> Bool {
		return lhs.unique_id <= rhs.unique_id
	}
	static func > (lhs: FirebaseTicket, rhs: FirebaseTicket) -> Bool {
		return lhs.unique_id > rhs.unique_id
	}
	static func >= (lhs: FirebaseTicket, rhs: FirebaseTicket) -> Bool {
		return lhs.unique_id >= rhs.unique_id
	}
*/
}
