//
//  FirebaseEmployee.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/11/17.
//  Copyright © 2017 user. All rights reserved.
//
import Firebase
import Foundation
class FirebaseEmployee : NSObject{
	var name:String?
	var id:String?
	var app_username:String?
	var app_password:String?
	var store_number:String?
	var store_phone:String?
	
	var phone:String?
	var type:String?//{}OWNER,EMPLOYEE,MANAGER are the types
	
	
	convenience init(emp:FirebaseEmployee,name:String,email:String){
		self.init()
		self.name = name
		self.id = Utils.generateID(username: email)
		self.app_username = email
		self.app_password = emp.store_phone!.sha1()
		self.store_phone = emp.store_phone
		self.store_number = emp.store_number
		self.phone = "N/A"
		self.type = "EMPLOYEE"
		
	}
	
	//CONVERT DATASNAPSHOT TO THIS OBJECT
	convenience init(snapshot : FIRDataSnapshot){
		self.init()
		for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? []{
			if responds(to: Selector(child.key)){
				setValue(child.value, forKey: child.key)
			}
		}
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
}
