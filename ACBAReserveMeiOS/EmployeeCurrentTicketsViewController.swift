//
//  EmployeeCurrentTicketsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import Firebase

class EmployeeCurrentTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var ticketsTableView: UITableView!
	
	
	var employee:FirebaseEmployee?
	var tickets:[FirebaseTicket] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let tb = self.tabBarController as! CustomTabBarController
		self.employee = tb.employee
		
		self.ticketsTableView.dataSource = self
		self.ticketsTableView.delegate = self
		let ref = FIRDatabase.database().reference().child("tickets/\(self.employee!.store_number!)")
		ref.observe(FIRDataEventType.value, with: {(snapshot) in
		
			for ds in snapshot.children{
				let t = FirebaseTicket(snapshot: ds as! FIRDataSnapshot)
				if !self.tickets.contains(t){
					self.tickets.append(t)
				}
			}
			self.tickets.sort(by: {$0.unique_id < $1.unique_id})
			self.ticketsTableView.reloadData()
		})//end observ
		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tickets.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = self.ticketsTableView.dequeueReusableCell(withIdentifier: "ct_viewcell") as! CurrentTicketsTableViewCell
		let t = self.tickets[indexPath.row]
		cell.ticket_number_label.text = t.unique_id.description
		cell.stylist_label.text = t.stylist.uppercased()
		cell.client_name.text = t.name.uppercased()
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//give warning to delete
		let t = self.tickets[indexPath.row]
		var alert = UIAlertController(title: "Deleted tickets cannot be restored.", message: "Are you sure you want to delete ticket?", preferredStyle: .alert)
		let action = UIAlertAction(title: "Cancel", style: .cancel){
			action in
			
		}
		let ok = UIAlertAction(title: "YES", style: .default){
			action in
			self.deleteTicket(ticket: t)
		}
		alert.addAction(action)
		alert.addAction(ok)
		self.present(alert, animated: true, completion: nil)
	}
	func deleteTicket(ticket:FirebaseTicket){
		let ref = FIRDatabase.database().reference().child("tickets/\(self.employee!.store_number!)")
		ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
			if currentData.childrenCount > 0 {
				
				var ticket_list:[[String:AnyObject]] = []
				for key in currentData.children.allObjects as! [FIRMutableData] {
					let dict = key.value as! [String:AnyObject]
					if (dict["unique_id"] as! CLong) == ticket.unique_id{//dont add
					}else{
						ticket_list.append(dict)
					}
				}
				currentData.value = ticket_list
				return FIRTransactionResult.success(withValue: currentData)
			}//end if somethings there NOT NILL
			else{//first ticket
				var a:[String:AnyObject] = [:]
				currentData.value = a
			}
			return FIRTransactionResult.success(withValue: currentData)
		}){ (error, committed, snapshot) in
			if let error = error {
				print(error.localizedDescription)
			}else{
				//self.showReceipt(userTicket:user_ticket)
				//self.updateCurrentTicketForStore(userTicket:user_ticket)
			}
		}
		
	}
	
}
