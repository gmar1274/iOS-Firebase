//
//  StylistTableViewCell.swift
//  ReserveMe
//
//  Created by user on 8/17/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class StylistTableViewCell: UITableViewCell {

	@IBOutlet weak var available: UILabel!
	@IBOutlet weak var stylist_image: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var people_waiting: UILabel!
	@IBOutlet weak var approx_wait_time: UILabel!
	@IBOutlet weak var reserve_time_estimate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
