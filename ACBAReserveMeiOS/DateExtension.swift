//
//  DateExtension.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/31/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation
extension Date{
	
	func isAfterDate(dateToCompare: Date) -> Bool {
		//Declare Variables
		var isGreater = false
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: dateToCompare)
		let min = calendar.component(.minute, from: dateToCompare)
		
		let myhour = calendar.component(.hour, from:self)
		let mymin = calendar.component(.minute, from:self)
		
		//Compare Values
		if self.compare(dateToCompare) == ComparisonResult.orderedDescending {//&& myhour >= hour && mymin >= min {
				isGreater = true
			}
			

		//Return Result
		return isGreater
	}
	
	func isBeforeDate(dateToCompare: Date) -> Bool {
		//Declare Variables
		var isLess = false
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: dateToCompare)
		let min = calendar.component(.minute, from: dateToCompare)
		
		let myhour = calendar.component(.hour, from:self)
		let mymin = calendar.component(.minute, from:self)
		
		//Compare Values
		if self.compare(dateToCompare) == ComparisonResult.orderedAscending {//&& myhour <= hour && mymin <= min {
			isLess = true
		}
		
		//Return Result
		return isLess
	}
	
	func equalToDate(dateToCompare: Date) -> Bool {
		//Declare Variables
		var isEqualTo = false
		//Compare Values
		if self.compare(dateToCompare) == ComparisonResult.orderedSame {
			isEqualTo = true
		}
		
		//Return Result
		return isEqualTo
	}
	func isSameDay(dateToCompare: Date) -> Bool {
	
		let calendar = Calendar.current
		let day = calendar.component(.day, from: dateToCompare)
		let month = calendar.component(.month, from: dateToCompare)
		let year = calendar.component(.year, from: dateToCompare)
		let myday = calendar.component(.day, from: self)
		let mymonth = calendar.component(.month, from: self)
		let myyear = calendar.component(.year, from: self)
		return day==myday && month==mymonth && year==myyear
	}
	
	}
