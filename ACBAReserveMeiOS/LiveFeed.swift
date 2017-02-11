//
//  LiveFeed.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/22/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit
import Firebase
import Stripe

class LiveFeed: UIViewController, UITableViewDelegate, UITableViewDataSource , STPPaymentContextDelegate, STPAddCardViewControllerDelegate , GADBannerViewDelegate{
	let TEST = true
	
	var paymentContext:STPPaymentContext?
	var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	
	let sc = "Stylist_Cell"
	@IBOutlet var stylistTableView: UITableView!
	var curr_index: Int = -1
	
	var mainTabController:MainTabControllerViewController?
	var stylist_array:[FirebaseStylist]=[]
	var store:FirebaseStore?
	var stylist_bitmaps:[String:Data] = [:]
	var amount:Int
	var cust_name:String
	var cust_email:String
	var hashMap:[String:FirebaseStylist] = [:]
	
	var ticketHistory:[FirebaseTicket] = []
	@IBOutlet var store_name_label: UILabel!
	
	init(){
		self.myAPIClient = POSTAPIClient()
		self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())
		self.amount = 100
		self.cust_name = "anon"
		self.cust_email = "gnmartinezedu@hotmail.com"
		super.init(nibName: nil, bundle: nil)
	}
	
	
	required init(coder aDecoder: NSCoder) {
		self.myAPIClient = POSTAPIClient()
		self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())
		self.amount = 100
		self.cust_name = "anon"
		self.cust_email = "gnmartinezedu@hotmail.com"
		super.init(coder: aDecoder)!
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.adBannerView.adSize = kGADAdSizeSmartBannerPortrait
		self.adBannerView.delegate = self
		self.adBannerView.rootViewController = self
		//self.adBannerView.isHidden = true
		/*App ID: ca-app-pub-9309556355508377~2611344846
		Ad unit ID: ca-app-pub-9309556355508377/8459402040
		*/
		self.adBannerView.adUnitID = "ca-app-pub-9309556355508377/8459402040"
		var request:GADRequest = GADRequest()
		if TEST {
		 request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
		}
		self.adBannerView.load(request)
		
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
	/***
	GETS CALLED FROM TABLE VIEW ON BUTTON SELETEC
	*/
	func requestBtn(_ stylist:UIButton){
		
		let nf = NumberFormatter()
		nf.currencySymbol = "$"
		nf.numberStyle = .currency
		let price = nf.string(from: NSNumber(value: store!.ticket_price!))
		let alert = UIAlertController(title: "The price to reserve a ticket will be \(price!)", message: "All tickets are non refundable. All transactions are done securely.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
		alert.addAction(UIAlertAction(title:"OK",style: .default){ action in
				let index = stylist.tag
				self.curr_index = index
				//creditCardDialog(index:index)
				//self.paymentContext?.requestPayment()
				
				//self.showAddCard()//this ,ethod shows to add card and processes it
				self.updateFirebaseTickets()
			})
		self.present(alert, animated: true, completion: nil)
		
		
	}
	func creditCardDialog(index:Int){
		
		
		var ccv = storyboard?.instantiateViewController(withIdentifier: "ccvc") as! CreditCardView
		ccv.store = self.store!
		ccv.stylist = self.stylist_array[index]
		present(ccv , animated: true, completion: nil)
		
		
	}//////////end credit ard dialog
	
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	var myAPIClient:POSTAPIClient
	/****
	MAIN CODE.
	THIS WILL POPULATE ALL STYLISTS AND BITMAPS CORRESPONDING TO STORE.
	*/
	@IBOutlet var adBannerView: GADBannerView!
	func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
		self.adBannerView.isHidden = true
	}
	func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
		self.adBannerView.isHidden = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		//start init
		self.paymentContext = STPPaymentContext(apiAdapter: myAPIClient)
		//super.init(nibName: nil, bundle: nil)
		super.viewWillAppear(animated)
		self.paymentContext?.delegate = self
		self.paymentContext?.hostViewController = self
		//self.paymentContext?.paymentAmount = 5000 // This is in cents, i.e. $50 USD
		
		////end int
		
		self.store = self.mainTabController?.store//always updating ..
		
		
		if store == nil {
			return
		}else if stylist_array.count>0 && stylist_array[0].store_number! == store!.store_number!{
			return
		}
		self.hashMap.removeAll()
		
		self.store_name_label.text = store!.name!
		self.amount = Int((store?.ticket_price)! * 100)//could be bug ...
		//print("amount ticket:: \(self.amount)")
		self.paymentContext?.paymentAmount = self.amount
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
	
	//Helper function to formulate line for a given stylist..
	func grabLine(forStylistID: String, ticketLineForStylist:[ArraySlice<[String:AnyObject]>]) -> [CLong]{
		if ticketLineForStylist.count == 0 {
			return []
		}
		var arr:[CLong] = []
		let t_arr = Array(ticketLineForStylist)
		for slice in t_arr{
			for i in slice.indices{
				let tn = slice[i]["unique_id"] as! CLong
				arr.append(tn)
			}
		}
		return arr
	}
	/***
	THIS FUNCTION WILL PREDICT THE WAIT TIME FOR A POTENTIAL TICKET.
	WILL RELOAD THE TABLE VIEW AFTER IT MAKES ITS PREDICTION.
	ALGORITHMN: NO_PREF Queue pop till it equally distributes all stylists..set pseudo wait and time for stylist_array
	*/
	func predictTimeForNewTicket(ticket_list:[[String:AnyObject]], nextTicket: Int){
		if ticket_list.count == 0{
			self.stylistTableView.reloadData()
			return
		}
		var q:[String:[CLong]] = [:]// queue for each stylist
		for sty in self.stylist_array{
			let sty_wait_list = ticket_list.split(whereSeparator:{ (($0["stylist_id"]) as! String) != sty.id!})//has all elements of the array as user_ticket -> stylist_id
			//print("\nt_list: \(t_list)\n")//it is an array of ArraySlice
			//for some reason array splice works with containing all elements not as specified by predicate..so not not equals will give me the array of only ..
			q[sty.id!] = grabLine(forStylistID: sty.id!, ticketLineForStylist: sty_wait_list )
			//print("ID:\(sty.id!) Q: \(q[sty.id!])")
		}
		//let temp_ticket = ticket_list
		var pref_q = q["-1"] //the line for store
		q.removeValue(forKey: "-1")
		
		while (pref_q?.count)! > 0 {
			var element = pref_q?[0]
			//print("while loop: elem: \(element)")
			if(element == nil){
				break
			}
			for sty_q in q.keys{ //all thats non -1
				if q[sty_q]?.count==0 || element! < (q[sty_q]?[0])! {
					q[sty_q]?.insert(element!, at: 0)
				}else{
					var wait_line = q[sty_q]
					wait_line?.append(element!)
					wait_line?.sort(by: {$0 < $1})
					q[sty_q] = wait_line
				}
				pref_q?.removeFirst()
				if((pref_q?.count)! > 0){
					element = pref_q?[0]
				}else{
					break
				}
			}
		}
		for sty in q.keys{
			q[sty]?.append(nextTicket)
		}
		//print("\nOrdered Q: \(q)\n")
		
		//stylist_array should be set from a previous call to firebase db
		//now we need to just update the array with our new predictive data
		var sty_arr:[FirebaseStylist] = []
		var lowest_time:[Int] = [] //id of lowest wait
		for sty in self.stylist_array {
			let s = self.hashMap[sty.id!]
			if q[sty.id!] == nil{//store_id == -1
			}else{
				s?.pseudo_wait = Int((q[sty.id!]?.index(of: nextTicket))!)
				sty_arr.append(s!)
				lowest_time.append((s?.pseudo_wait)!)
			}
		}
		lowest_time.sort(by: {$0<$1})
		var store = self.hashMap["-1"]
		store?.pseudo_wait = lowest_time[0]
		sty_arr.insert(store!, at: 0)
		
		self.stylist_array.removeAll()
		self.stylist_array = sty_arr
		self.stylistTableView.reloadData()
	}
	func loadStylistFirebase(alert:UIAlertController){
		
		self.stylist_array.removeAll()
		self.stylist_array = []
		self.stylist_bitmaps.removeAll()//clear
		self.stylist_bitmaps = [:]
		
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
				self.hashMap[sty.id!] = sty
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
						self.ticketListener()
						
						alert.dismiss(animated: true, completion: nil)
					}
				}
			})//end statement
		}
		
			}
	/**LOAD DATA FROM FIREBASE.THIS method sets the listerner for this viewcontroller**/
	@IBOutlet var curr_ticket_label: UILabel!
	@IBOutlet var your_ticket_label: UILabel!
	/**Add listener to firebase to update GUI apon data change...*/
	func ticketListener(){
		let store_ref = FIRDatabase.database().reference().child("user/\(store!.store_number!)/current_ticket")
		store_ref.observe(FIRDataEventType.value, with: { snapshot in
			//print("in store... : \(snapshot)")
			let value = snapshot.value as! CLong
			self.store!.current_ticket = value
			var sum = 0
			for sty in self.stylist_array{
				sum += sty.wait!
			}
			if sum == 0{
				self.curr_ticket_label.text = value.description
			}//self.your_ticket_label.text = (value+1).description
		})
		
		
		let tick_ref = FIRDatabase.database().reference().child("tickets/\(store!.store_number!)")
		tick_ref.observe(FIRDataEventType.value, with: { (snapshot) in
			//print("\nIN ticket listener: \(snapshot.value)")
			//get value
			
			////could have a nil because of deletion in firebase...idk but yeah...swift...
			//so let manulally create a new [[String:anyobj]] this will rid all nils and do what
			//we initially wanted
			var tickets:[[String:AnyObject]] = []
			for key in (snapshot.children.allObjects as? [FIRDataSnapshot])! {
				tickets.append(key.value as! [String : AnyObject])
			}
			if tickets.count > 0//snapshot.value as? [[String:AnyObject]]
			{
				let value = tickets
				self.resetWaitForStylists()//clear existing values for sty in hashmap
				let curr = value[0]["unique_id"] as! CLong
				self.store!.current_ticket = curr
				
				let next_ticket = value[value.count-1]["unique_id"] as! CLong
				self.curr_ticket_label.text = curr.description
				self.your_ticket_label.text = (next_ticket+1).description
				for ds in value{
					let id = ds["stylist_id"] as! String
					//let tn = CLong(ds["ticket_number"] as! String)
					let sty = self.hashMap[id]
					sty!.wait! += 1
					self.hashMap[id] = sty
				}
				self.predictTimeForNewTicket(ticket_list: value, nextTicket: Int(next_ticket+1))//will reload the data
			}else{
				let curr = self.store!.current_ticket
				self.curr_ticket_label.text = curr.description
				self.your_ticket_label.text = (curr+1).description
				self.zeroOutStylistWaiting()
				self.stylistTableView.reloadData()
			}
			return
		})//end observor
	}
	func zeroOutStylistWaiting(){
		var arr:[FirebaseStylist] = []
		for sty in self.stylist_array{
			sty.wait = 0
			sty.pseudo_wait = 0
			arr.append(sty)
		}
		self.stylist_array.removeAll()
		self.stylist_array = arr
	}
	
	/**
	Clears the wait for stylists...
	*/
	func resetWaitForStylists(){
		for id in self.hashMap.keys{
			let sty = self.hashMap[id]
			sty!.wait = 0
			self.hashMap[id] = sty
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
		/*
		let cell = tableView.dequeueReusableCell(withIdentifier: sc, for: indexPath)
		cell.accessoryType = .checkmark
		
		if( indexPath.row != curr_index && curr_index >= 0){
			let i = IndexPath(row: curr_index, section: 0)
			let old = tableView.dequeueReusableCell(withIdentifier: sc, for: i)
			old.accessoryType = .none
		
		}
		*/
			curr_index = indexPath.row
		
		
	}
	
	
	/////end tableView functions
	///////api functions
	
	func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
		//self.activityIndicator.isAnimating = paymentContext.loading
		self.activityIndicator.startAnimating()
		
		//self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
		//self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
		//self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
	}
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didCreatePaymentResult paymentResult: STPPaymentResult,
	                    completion: @escaping STPErrorBlock) {
		
  myAPIClient.completeCharge(token:paymentResult.source.stripeID ,amount: 1220,name:"ANON",email:"gnmartinezedu@hotmail.com" , completion: { (error: Error?) in
	if let error = error {
		completion(error)
	} else {
		completion(nil)
	}
})
	}
	
	///////ADD CARD DELEGATE
	func showAddCard() {
		let addCardViewController = STPAddCardViewController()
		addCardViewController.delegate = self
		// STPAddCardViewController must be shown inside a UINavigationController.
		let navigationController = UINavigationController(rootViewController: addCardViewController)
		self.present(navigationController, animated: true, completion: nil)
	}
	
	// MARK: STPAddCardViewControllerDelegate
	//This method will determine whether to send a stripe token or not. So I send the tokenm to my
	//server to validate whether its valid or not.
	func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
		self.dismiss(animated: true, completion: nil)
	}
	func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
		
		myAPIClient.completeCharge(token:token.stripeID ,amount: self.amount,name:self.cust_name,email:self.cust_email , completion: { (error: Error?) in
			if let error = error {
				completion(error)
				self.showError(err: error,msg:"Try again...",title:"Credit card failed")
			} else {
				
				self.dismiss(animated: true, completion: {
					self.updateFirebaseTickets()
				
					completion(nil)
				})
			}
		})
		
	}
	
	
	
	
	
	///////////end add card
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFinishWith status: STPPaymentStatus,
	                    error: Error?) {
		
		switch status {
		case .error:
			self.showError(err: error!,msg:"Credit card failed. No Transaction was made.",title:"Error")
		case .success:
			//self.showReceipt(userTicket: nil)
			return
		case .userCancellation:
			return // Do nothing
		}
	}
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFailToLoadWithError error: Error) {
		self.navigationController?.popViewController(animated: true)
		// Show the error to your user, etc.
	}
	
	
	func showReceipt(userTicket:FirebaseTicket) {
		print("int receipt code...")
		let curr_sty = self.stylist_array[self.curr_index]
		userTicket.readyBy = curr_sty.getReadyByDateFormat()
		self.ticketHistory.append(userTicket)
		let tc = self.tabBarController as! MainTabControllerViewController
		tc.pastTickets = self.ticketHistory//update list
		
		self.displayAlertMsgDialog(msg: "Transaction was successful.", title: "Your ticket # is: \(userTicket.unique_id)")
	}
	
	func showError(err:Error,msg:String,title:String){
		self.displayAlertMsgDialog(msg: msg, title: title)
		print("in err code: \(err)")
		
	}
	func displayAlertMsgDialog(msg:String,title:String)  {
		var alert = UIAlertController(title: title, message:msg, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .cancel)
		alert.addAction(ok)
		self.present(alert, animated: true, completion: nil)
	
	}
	
	//////end api
	/**
	* UPDATES THE NEW TICKET
	*/
	func updateFirebaseTickets(){
		let sty = self.stylist_array[self.curr_index]
		var user_ticket = FirebaseTicket(unique_ticket: sty.wait!+1, sty: sty)
		
		let ref = FIRDatabase.database().reference().child("tickets/\(self.store!.store_number!)")
	
		ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
			
			//print("\n\nSNAPSHOT:: \(currentData.value)\n\n")
		if currentData.childrenCount > 0 {
			
			////could have a nil because of deletion in firebase...idk but yeah...swift...
			//so let manulally create a new [[String:anyobj]] this will rid all nils and do what 
			//we initially wanted
			var tickets:[[String:AnyObject]] = []
			for key in currentData.children.allObjects as! [FIRMutableData] {
				tickets.append(key.value as! [String : AnyObject])
			}
			////
			tickets.sort(by: {( ($0["unique_id"] as! CLong) < ($1["unique_id"] as! CLong) )})//sort by lowest to highest og absolute ticket
				//print("in trans:: \(tickets)")
				user_ticket.unique_id = tickets[tickets.count-1]["unique_id"] as! CLong
				user_ticket.unique_id += 1
				let t_list = tickets.split(whereSeparator:{ (($0["stylist_id"]) as! String) != user_ticket.stylist_id})//has all elements of the array as user_ticket -> stylist_id
				//print("\nt_list: \(t_list)\n")//it is an array of ArraySlice
				if t_list != nil && t_list.count > 0 { //there exists stylist_id with an existing ticket_number... so lets get the latest number to update our user ticket for sty
					let ticket_ahead_of_user  = t_list[t_list.count-1].sorted(by: ({ (CLong($0["ticket_number"] as! String) )! > ( CLong($1["ticket_number"] as! String) )!} )) //sort all subset that contains stylist id by -> ticket_number trying to get the max
					//print("\n\nTEMP:: \(temp)")
					let ft = ticket_ahead_of_user[0]["ticket_number"] as! String
					let max_ticket_number = CLong(ft)
					user_ticket.ticket_number = (max_ticket_number! + 1).description
				}else{//first in list
					user_ticket.ticket_number = "1"
				}
				let map = user_ticket.getDictionaryFormat()
				tickets.append(map)
				currentData.value = tickets
				return FIRTransactionResult.success(withValue: currentData)
			}//end if somethings there NOT NILL
			else{//first ticket
				var a:[String:AnyObject] = [:]
				user_ticket.ticket_number = "1"
				user_ticket.unique_id = self.store!.current_ticket + 1
				let map = user_ticket.getDictionaryFormat()
				a["0"] = map as AnyObject?
				currentData.value = a
			}
			
			return FIRTransactionResult.success(withValue: currentData)
		}){ (error, committed, snapshot) in
			if let error = error {
				print(error.localizedDescription)
			}else{
				self.showReceipt(userTicket:user_ticket)
				self.updateCurrentTicketForStore(userTicket:user_ticket)
			}
		}
		
	}
	func updateCurrentTicketForStore(userTicket:FirebaseTicket)  {
		FIRDatabase.database().reference().child("user/\(store!.store_number!)/current_ticket").runTransactionBlock({ (currData: FIRMutableData)-> FIRTransactionResult in
			let valueToUpdate = userTicket.unique_id //self.store!.current_ticket
			
			//print("transaction store: \(currData.value) vs.. \(valueToUpdate)")
			if let value = currData.value as? CLong{
				if valueToUpdate > value{
					currData.value = valueToUpdate
				}
			}else{
				currData.value = valueToUpdate
			}
			return FIRTransactionResult.success(withValue: currData)
		})
	}
}
