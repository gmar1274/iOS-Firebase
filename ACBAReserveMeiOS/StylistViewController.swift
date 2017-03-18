//
//  StylistViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/3/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class StylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var date_label: UILabel!
	static var reservationDetails:ReservationDetails?
	var store_id:CLong = -1
	var stylist_id:String = ""
	var stylist:Stylist?
	static var reservations:Reservation? // set from the api web request
	static var stylist:Stylist?
	var reservations:Reservation?
	 var isUpcoming:Bool = false
	var date:String = ""
	var timeArray:[TimeSet] = []
	@IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		let df = DateFormatter()
		df.dateFormat = "MMM/dd/yyyy"
		var date:String = ""
		let tab = self.tabBarController as! CustomTabBarController
		if isUpcoming {
			//date = UpcomingAppointmentsViewController.date
			self.timeArray = (self.reservations?.getTimeSetArrayForDate(date: self.date))!
			self.date_label.text = self.date
		}else{
			 date = df.string(from: Date())
				self.date_label.text = date
		self.store_id = CLong(tab.store_id)!
		self.stylist_id = tab.sty_id
		}
		self.tableView.delegate = self
		self.tableView.dataSource = self
		if reservations == nil {
			PostRequest.stylistWebTaskAppointments(svc: self, stylist_id: self.stylist_id, store_id: self.store_id)
		}
		////MAKE THE REQUEST FROM DATABSE TO POPULATE APPOINTMENTS
		// TO  DISPLAY FOR THE TABS today and upcoming views
        // Do any additional setup after loading the view.
    }
	func setStylist(sty:Stylist){
		self.stylist = sty
		StylistViewController.stylist = sty
	}
	func setReservation(rs:Reservation){
		self.reservations = rs
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	////////////////////////////////start table view methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isUpcoming {
			return self.timeArray.count
		}else{
		if self.reservations == nil || self.stylist == nil{
			return 0
		}
		return self.timeArray.count
		}
	}
	
	func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if isUpcoming {
			let cell = tableView.dequeueReusableCell(withIdentifier: "sacell", for:indexPath) as! StylistTodayAppointmentsTableViewCell
		
			let title = self.timeArray[indexPath.row].display12HourFormat()
			cell.timeRange_label.text = title//cell.btn_timerange.setTitle(title, for: .normal)
			
			return cell
			
		}else{
		let cell = tableView.dequeueReusableCell(withIdentifier: "sacell", for: indexPath) as! StylistTodayAppointmentsTableViewCell
		let title:String = self.timeArray[indexPath.row].display12HourFormat()//
		//cell.btn_timerange.setTitle(title, for: .normal)
		cell.timeRange_label.text = title
			return cell
		}
	}
	func transfer(indexPath:IndexPath){
		
		StylistViewController.reservationDetails = self.reservations?.getReservationDetails(ts:  self.timeArray[indexPath.row])
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "RDVC") as! CellViewController
		vc.reservationDetails = StylistViewController.reservationDetails
		vc.dateString = self.date_label.text!
		vc.timeRangeString = self.timeArray[indexPath.row].display12HourFormat()
		self.present(vc, animated: true, completion: nil)
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		transfer(indexPath:indexPath)
		
	}
	func displayToday(){
		self.timeArray = (self.reservations?.getAppointments(sty: self.stylist!, day: Date()))!
		//the reservations should be not null but at least have been called by the API web service this is how this method gets called only after a successful connection to the DB
		
		self.tableView.reloadData()
		//display today GUI
	}
	func error(msg:String){
		let ac = UIAlertController(title: "Erorr", message: msg, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		ac.addAction(defaultAction)
		self.present(ac, animated: true, completion: nil)
	}
	@IBAction func back(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

}
