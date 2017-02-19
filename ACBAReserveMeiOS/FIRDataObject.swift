//
//  FIRDataObject.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/5/17.
//  Copyright © 2017 user. All rights reserved.
//
import Firebase
import CoreLocation
class FIRDataObject: NSObject{
	let snapshot: FIRDataSnapshot
	var key: String{return snapshot.key}
	var ref: FIRDatabaseReference{return snapshot.ref}
	public var coordinate: CLLocationCoordinate2D
	public var title:String?
	public var subtitle:String?
	required init(snapshot: FIRDataSnapshot){
		self.snapshot = snapshot
		self.coordinate = CLLocation(latitude: 0, longitude: 0).coordinate
		self.title=""
		self.subtitle=""
		super.init()
		for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? []{
			//print("CHILD IN FIROBJJ:: \(child)\n\nKEYY: \(child.key)\n\nVALUEE: \(child.value)\n")
			if responds(to: Selector(child.key)){
				setValue(child.value, forKey: child.key)
			}
		}
	}
}
