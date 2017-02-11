//
//  CurrentTicketsTableViewCell.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class CurrentTicketsTableViewCell: UITableViewCell {

	@IBOutlet var ticket_number_label: UILabel!
	
	@IBOutlet var stylist_label: UILabel!
	
	@IBOutlet var client_name: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
