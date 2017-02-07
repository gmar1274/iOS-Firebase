//
//  CellViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/3/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class CellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var reservationDetails: ReservationDetails?
	var dateString:String = ""
	var timeRangeString:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
		//not sure it matters whos calling this ciewcontroller
		//however the only way this class is called is if there a reservationDetail from 
		// the Stylist ViewController class thus SVC.reservationDetails is not null
		if self.reservationDetails == nil{
		self.reservationDetails = StylistViewController.reservationDetails
		}
		self.timeRangeBtn.text = self.timeRangeString
		self.date.text = self.dateString
		self.tableView.delegate = self
		self.tableView.dataSource = self
    }
	@IBOutlet var timeRangeBtn: UILabel!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	////////////////////////////////start table view methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "rdcell", for: indexPath) as! ReservationDetailsTableViewCell
		let r = self.reservationDetails!
		cell.client_name.text = r.customer.name.uppercased()
		cell.comments.text = r.notes
		cell.service.text = r.service_name
		cell.contact_info.text = r.customer.phone
		
		
		return cell
	}
	override func viewWillDisappear(_ animated: Bool) {
		self.dismiss(animated: true, completion: nil)
	}
	@IBOutlet var date: UILabel!/////date label

	@IBOutlet var tableView: UITableView!
	@IBOutlet var time: UIView!
	@IBAction func back(_ sender: Any) {
		self.dismiss(animated:true,completion:nil)
	}
}
