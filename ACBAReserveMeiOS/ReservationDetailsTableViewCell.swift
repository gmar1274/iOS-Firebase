//
//  ReservationDetailsTableViewCell.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/3/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class ReservationDetailsTableViewCell: UITableViewCell {
	@IBOutlet var client_name: UILabel!

	@IBOutlet var contact_info: UILabel!
	
	@IBOutlet var service: UILabel!
	
	@IBOutlet var comments: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
