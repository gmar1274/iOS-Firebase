//
//  LiveFeed.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/22/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit
import Firebase
class LiveFeed: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let sc = "Stylist_Cell"
	@IBOutlet var stylistTableView: UITableView!
	var curr_index: Int = -1
	
	var mainTabController:MainTabControllerViewController?
	var stylist_array:[FirebaseStylist]=[]
	var store:FirebaseStore?
	var stylist_bitmaps:[String:Data] = [:]
	override func viewDidLoad() {
		super.viewDidLoad()
		stylistTableView.delegate=self
		stylistTableView.dataSource=self
		self.mainTabController = self.tabBarController as! MainTabControllerViewController
		self.stylist_bitmaps = [:]
	}
	
	//////////////////////tableview
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		
		let stylist = stylist_array[indexPath.row] //get stylist at pos index from the current store
		
		let cell = tableView.dequeueReusableCell(withIdentifier: sc, for: indexPath) as! StylistCellView
		
		cell.stylistName.text = stylist.name!.uppercased()
		cell.waitingLabel.text = "\(stylist.wait!)"
		cell.approxWait.text = stylist.getApproxWait()
		cell.readyBy.text = stylist.getReadyByDateFormat()
		cell.requestTicketBtn.tag = indexPath.row
		cell.requestTicketBtn.addTarget(self, action: #selector(LiveFeed.requestBtn(_:)), for: .touchUpInside)
		cell.callBtn.addTarget(self, action: #selector(LiveFeed.call(_:)), for: .touchUpInside)
		cell.stylistImageView.image = UIImage(data: self.stylist_bitmaps[stylist.id!]!)
		
		return cell
		
	}
	 func call(_ stylist:UIButton){
		let index = stylist.tag
		let sty = self.stylist_array[index]
		if sty != nil && sty.phone != nil {
			Utils.callNumber(sty.phone!)
		}
	}
	func requestBtn(_ stylist:UIButton){
		let index = stylist.tag
		creditCardDialog(index:index)
		
		
	}
	func creditCardDialog(index:Int){
		
		
		//let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.ActionSheet)
		//alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
		
		
		//let customView = CreditCardView()//(frame: CGRect(x: 0, y: 0, width: alert.view.frame.width, height: alert.view.frame.height))
		
		//add this line here
		//customView.sizeToFit()
		//alert.view.addSubview(customView);
		
		var ccv = storyboard?.instantiateViewController(withIdentifier: "ccvc") as! CreditCardView
		ccv.store = self.store!
		ccv.stylist = self.stylist_array[index]
		present(ccv , animated: true, completion: nil)
		
		
	}//////////end credit ard dialog
	
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func viewWillAppear(_ animated: Bool) {
		
		
		self.store = self.mainTabController?.store//always updating ..
		
		
		if store == nil {
			return
		}else if stylist_array.count>0 && stylist_array[0].store_number! == store!.store_number!{
			return
		}
		
		var alert = UIAlertController(title: "Loading stylists", message: "Please wait...", preferredStyle: .alert)
		
		alert.view.tintColor = UIColor.black
		
		let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingIndicator.startAnimating();
		
		alert.view.addSubview(loadingIndicator)
		present(alert, animated: true, completion: nil)//display seraching
		//print("OTHER method: Store\(self.store?.name)")// prints out current store..
		loadStylistFirebase(alert:alert)
		super.viewWillAppear(animated)
	}
	func loadStylistFirebase(alert:UIAlertController){
		
		self.stylist_array.removeAll()
		self.stylist_bitmaps.removeAll()//clear
		
		//make firebase connection for stylist images and for stylist info...
		//get stylist info then loop for every stylist for their image
		//print("Store Number: \(store!.store_number!)")// need to force unwrap becuz its assumed at this point the store exists
		FIRDatabase.database().reference().child("stylists/\(store!.store_number!)").observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
		/* let dict = snapshot.value as? [String : AnyObject] ?? [:]
			for a in dict.keys{
				print("Keys: \(a) ")//value: \(dict[a])")
			}
			print("VALUE: \(snapshot.value)")
			*///this gets the datashot as a map<String,Obj>
			for ds in snapshot.children{
				var sty = FirebaseStylist(snapshot: ds as! FIRDataSnapshot)
				
				let dict = (ds as! FIRDataSnapshot).value as? [String : AnyObject] ?? [:]
				sty.store_number = self.store!.store_number!
				sty.wait = dict["wait"] as! Int ?? 0
				self.stylist_array.append(sty)
			}
			self.stylist_array.sort(by: {$0.id! < $1.id!})
			self.loadFirebaseImages(alert:alert)
			
		})//end single event listener

	}//end method
	func loadFirebaseImages(alert:UIAlertController){
		//var index = 0
		for sty in self.stylist_array{
		let storage = FIRStorage.storage().reference().child("\(store!.phone!)/images/stylists/\(sty.id!)")
			storage.data(withMaxSize: 10*1024*1024, completion: { data, error in//10 mb
				if let error = error{
					print("file error download exit...err: \(error)")
					
				}else{
					print("image success...")
					self.stylist_bitmaps[sty.id!] = data!
					
					
					if self.stylist_bitmaps.values.count == self.stylist_array.count{//finished
						self.stylistTableView.reloadData()
						alert.dismiss(animated: true, completion: nil)
					}
				}
			})//end statement
		}
		
			}
	
	
	/**
	I want to open dialog that ask if they want to make a call
	*/
	func imageTapped(_ img:AnyObject) {
		
	}
	// number of rows in table view
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stylist_array.count
	}
	
	// if tableView is set in attribute inspector with selection to multiple Selection it should work.
	// Just set it back in deselect
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: sc, for: indexPath)
		cell.accessoryType = .checkmark
		
		if( indexPath.row != curr_index && curr_index >= 0){
			let i = IndexPath(row: curr_index, section: 0)
			let old = tableView.dequeueReusableCell(withIdentifier: sc, for: i)
			old.accessoryType = .none
		
		}
		
			curr_index = indexPath.row
		
		
	}
	
	
	/////end tableView functions
	
	
	
}
