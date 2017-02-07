//
//  StylistTableViewCell.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/28/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class StylistTableViewCell: UITableViewCell {

	
	@IBOutlet var stylist_image: UIImageView!
	
	@IBOutlet var stylist_name: UILabel!
	
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
