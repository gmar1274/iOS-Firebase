//
//  AppointmentViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/29/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class AppointmentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet var dateLabel: UILabel!

	@IBOutlet var stylistLabel: UILabel!
	
	@IBOutlet var serviceLabel: UILabel!
	
	@IBOutlet var priceLabel: UILabel!
	
	
	@IBOutlet var durationLabel: UILabel!
	
	
	@IBOutlet var timePicker: UIPickerView!
	var available_timeranges:[TimeSet]?
	var current_value:TimeSet?
	
	var store_list:[Store]=[]
	var selectedPosition:Int = -1
    override func viewDidLoad() {
		self.available_timeranges = []//init empty array
        super.viewDidLoad()
		self.timePicker.delegate = self
		self.timePicker.dataSource = self
		OperationQueue.main.addOperation {	//call back to main thread
			self.loadTimePicker()
		}
		initLabels()
        // Do any additional setup after loading the view.
    }
	func initLabels(){
		dateLabel.text = ReservationViewController.dateSelected() //from selected date
		let sty = ReservationViewController.getSelectedStylist()
		let service = ReservationViewController.getSelectedService()
		stylistLabel.text = sty.name.uppercased()
		serviceLabel.text = service.name.uppercased()
		priceLabel.text = service.getPriceFormatted()
		durationLabel.text = service.getDurationFormatted()
	}
	/**
	Establish the available time ranges. Get a reference to the store and its revervations for the specified stylist. Display the available time for the duration of the selected service dynamically
	*/
	func loadTimePicker(){
		let sty = ReservationViewController.getSelectedStylist()
		let store = store_list[selectedPosition]
		let day = ReservationViewController.dateSelectedAsDate()
		let service = ReservationViewController.selected_service!
		let taken_list = store.reservation.getAppointments(sty: sty, day: day) //array of timeset in order
		let open = store.open_hours!
		let close = store.close_hours!
		
		let open_date = setDate(date:day,time: open)
		let close_date = setDate(date:day, time: close)
		let seconds = Utils.getTimeToSeconds(duration: service.duration)
		generateAvailableTimes(start: open_date,end:close_date,picker: timePicker, duration: seconds, taken_list:taken_list)
	
	}
	func generateAvailableTimes(start:Date, end:Date, picker:UIPickerView, duration:CLong, taken_list:[TimeSet]){
		let store_ts = TimeSet(start: start, end: end)
		var pointer = store_ts.lower_bound //sjould be starting date set to hour=open
		
		var taken = taken_list
		
		while pointer.isBeforeDate(dateToCompare: store_ts.upper_bound) {
			
			let ts = TimeSet(start: pointer, duration: duration)//create a time range
			
				if !taken.isEmpty {
				let taken_ts = taken[0]
				if ts.isLowerBoundDisjoint(ts: taken_ts) && ts.isSubSet(ts: store_ts){
					self.available_timeranges?.append(ts)
					pointer = ts.upper_bound
				}else{
					pointer = taken_ts.upper_bound
					taken.remove(at: 0)
					
				}
			}else if ts.isSubSet(ts: store_ts){ ///taken is empty
				self.available_timeranges?.append(ts)
				pointer = ts.upper_bound
				
			}else{
				pointer = ts.upper_bound
			}
		}
		self.timePicker.reloadAllComponents() // hopefully reloads the view
	}
	func debug(){
		for ts in self.available_timeranges!{
			print("\nFormat: "+ts.display12HourFormat())
		}
	}
		//Takes a string in the format of hh:mm
	func setDate(date:Date, time:String) -> Date{
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		df.timeZone = TimeZone.ReferenceType.local
		let ddf = DateFormatter()
		ddf.dateFormat = "yyyy-MM-dd"
		let string = ddf.string(from: date)
		return df.date(from: string+" "+time)!		
}
	
	@IBAction func makeAppointment(_ sender: Any) {
		let ccd = storyboard?.instantiateViewController(withIdentifier: "ccvc") as! CreditCardView
		
		self.present(ccd, animated: true, completion: nil)
		ccd.updateFromAppointment(av: self)
	}
	@IBAction func cancel(_ sender: Any) {
		ReservationViewController.selected_stylist = nil//refresh
		ReservationViewController.selected_service = nil
		dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	/////////////////////////////////////uipicker delegate
	func numberOfComponents(in: UIPickerView) -> Int {
		return 1
	}
 
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return available_timeranges!.count;
	}
 
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return available_timeranges![row].display12HourFormat()
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		self.current_value = (self.available_timeranges?[row])! //selection
	}
	func displayCurerntValue()->String{
		if self.current_value == nil{
			return self.available_timeranges![0].display12HourFormat()
		}
		return self.current_value!.display12HourFormat()
	}
	///////////////////////////////end ui delegat
	

}
