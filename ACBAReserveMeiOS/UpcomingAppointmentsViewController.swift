//
//  UpcomingAppointmentsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/5/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class UpcomingAppointmentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableViewUpcoming: UITableView!
	
	var res = StylistViewController.reservations
	var sty = StylistViewController.stylist
	static var date:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
		res = StylistViewController.reservations
		sty = StylistViewController.stylist
		self.tableViewUpcoming.delegate = self
		self.tableViewUpcoming.dataSource = self
		self.tableViewUpcoming.reloadData()
		
		//print(" DAYS: \(res?.dayArray.count)") debug
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	////////////////////////////////start table view methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//let res = StylistViewController.reservations
		//let sty = StylistViewController.stylist
		if res == nil {
			return 0
		}
		return (res?.dayArray.count)!
		
	}
	
	func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingAppointments", for: indexPath) as! UpcomingTableViewCell
		let date = self.res?.dayArray[indexPath.row]
		cell.dateLabel.text = date
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UpcomingAppointmentsViewController.date = (res?.dayArray[indexPath.row])!
		let vc = storyboard?.instantiateViewController(withIdentifier: "StylistVC") as! StylistViewController
		vc.isUpcoming = true
		vc.stylist = self.sty
		vc.reservations = self.res
		UpcomingAppointmentsViewController.date = (self.res?.dayArray[indexPath.row])!
		vc.date = UpcomingAppointmentsViewController.date
		//vc.reservations = self.res
		self.present(vc, animated: true, completion: nil)
	}
	

}
