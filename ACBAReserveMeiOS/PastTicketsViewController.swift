//
//  PastTicketsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class PastTicketsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

	var tickets:[FirebaseTicket] = []
	
	@IBOutlet var ticketsTableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let tc = self.tabBarController as! MainTabControllerViewController
		self.tickets = tc.pastTickets
		
		self.ticketsTableView.delegate = self
		self.ticketsTableView.dataSource = self
		self.ticketsTableView.reloadData()
		
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tickets.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = self.ticketsTableView.dequeueReusableCell(withIdentifier: "pt_viewcell") as! PastTicketHistoryTableViewCell
		let t = self.tickets[indexPath.row]
		cell.ticket_number_label.text = t.unique_id.description
		cell.stylist_label.text = t.stylist.uppercased()
		cell.readyBy_label.text = t.readyBy!
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
}
