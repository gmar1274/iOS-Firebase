//
//  ReservationViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/28/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class ReservationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	 @IBOutlet  var service_tableView: UITableView!

	 @IBOutlet  var stylist_tableview: UITableView!
	
	static var stylist_tv:UITableView?
	static var service_tv:UITableView?
	var stylist_tv_index = -1
	var service_tv_index = -1
	var store_list:[Store] = []
	var selectedPostion:Int = -1
	static var datePickerReference:UIDatePicker?
	
	////
	static var selected_stylist:Stylist?
	static var selected_service:Service?
    override func viewDidLoad() {
		
        super.viewDidLoad()
		self.stylist_tableview.delegate=self
		self.stylist_tableview.dataSource=self
		self.service_tableView.delegate=self
		self.service_tableView.dataSource=self

		//init datepicker settings ie. set date min
		let today = Date()
		self.datePicker.minimumDate = today.addingTimeInterval(60*60*24)
		
		//
		ReservationViewController.stylist_tv = self.stylist_tableview
		ReservationViewController.service_tv = self.service_tableView
		ReservationViewController.datePickerReference = self.datePicker
		
		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	@IBAction func makeReservation(_ sender: Any) {
		let sty = ReservationViewController.selected_stylist
		let service = ReservationViewController.selected_service

		//reject if no stylist or service selected
		if (sty == nil || service == nil){return}//fix later potential bug need to clear variables when change of store...
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentViewController
		self.present(vc, animated: true, completion: nil)
	}
	@IBOutlet var datePicker: UIDatePicker!////////////date picker
	static func dateSelectedAsDate() -> Date {
		return datePickerReference!.date
	}
	static func dateSelected() -> String{
		let df = DateFormatter()
		df.dateFormat = "MMM/dd/yyyy"
		return df.string(from: datePickerReference!.date)
	}
	static func getSelectedStylist() -> Stylist {
		return selected_stylist!
	}
	static func getSelectedService() -> Service {
		return selected_service!
	}
    ////////////////////////////////start table view methods

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return the number of items in the sample data structure.
		let store = store_list[selectedPostion]
		var count:Int?
		
		if tableView == self.stylist_tableview {
			count = store.getStylistsForAppointments().count
		}else{
			count =  store.service_hm.count
		}
		
		return count!
		
	}
	
	func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let store = store_list[selectedPostion]
		
		if tableView == self.stylist_tableview {
			let sty = store.getStylistsForAppointments()[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "stylist_cell", for: indexPath) as! StylistTableViewCell
			cell.stylist_image.image = UIImage(data: sty.imageArray as Data)
			cell.stylist_name.text = sty.name
			return cell
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: "service_cell", for: indexPath as IndexPath) as! ServiceTableViewCell
			let service  = store.getServiceArray()[indexPath.row]
			cell.name.text = service.name
			cell.price.text = service.getPriceFormatted()
			cell.duration.text = service.getDurationFormatted()
			return cell
		}
		
	}
	
	
	func tableView( _ tableView:UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		
		if(tableView == self.stylist_tableview){
			
			ReservationViewController.selected_stylist = store_list[selectedPostion].getStylistsForAppointments()[indexPath.row]//update stylist
			self.stylist_tableview.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
			if(indexPath.row != stylist_tv_index && stylist_tv_index >= 0){///if not current selected
				let i = IndexPath(row: stylist_tv_index, section: 0)
				self.stylist_tableview.cellForRow(at: i)?.accessoryType = .none //set old uncheck
			}
			stylist_tv_index = indexPath.row//update curr pos
		}
		else{//service table view
			ReservationViewController.selected_service = store_list[selectedPostion].getServiceArray()[indexPath.row]//update service
			
			self.service_tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
			
			if(indexPath.row != service_tv_index && service_tv_index >= 0){//if not current selected
				let  i = IndexPath(row: service_tv_index, section: 0)
				self.service_tableView.cellForRow(at: i)?.accessoryType = .none//uncheck the old
			}///
			service_tv_index = indexPath.row
		}
		
	}
	
	///////////////////////////////////table view methods
}
