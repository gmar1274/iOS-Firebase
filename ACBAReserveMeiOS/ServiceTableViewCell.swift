//
//  ServiceTableViewCell.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/28/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {

	
	@IBOutlet var name: UILabel!
	
	@IBOutlet var price: UILabel!
	
	@IBOutlet var duration: UILabel!
	
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
