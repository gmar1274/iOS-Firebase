//
//  StylistTodayAppointmentsTableViewCell.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/3/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class StylistTodayAppointmentsTableViewCell: UITableViewCell{


	
	@IBOutlet var timeRange_label: UILabel!
	
	//var isPressed = false
	//var data:[ReservationDetails] = [] //empty dataset
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		//self.tableView2.delegate = self
		//self.tableView2.dataSource = self
		
    }
	
	/**
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "rdcell", for: indexPath) as! ReservationDetailsTableViewCell
		
		cell.client_name.text = "Test nameee"
		return cell
	}*/
}
