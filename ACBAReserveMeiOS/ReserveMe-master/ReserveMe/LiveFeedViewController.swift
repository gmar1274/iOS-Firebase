//
//  LiveFeedViewController.swift
//  ReserveMe
//
//  Created by user on 8/15/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class LiveFeedViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, StylistModelProtocal {
	var isLoad=false
	var storeID:Int = (-1)
	
	
	@IBOutlet weak var progressBar: UIActivityIndicatorView!
	@IBOutlet weak var table: UITableView!
	
	var feedItems: NSArray = NSArray()
	let cellID="cell"
	
	override func viewDidLoad() {
        super.viewDidLoad()
		isLoad=true
		load()
    }
	override func viewDidAppear(animated: Bool) {
		//super.viewDidAppear(animated)
		if(isLoad==false){
			load()
		}
	}
	override func viewDidDisappear(animated: Bool) {
		isLoad=false
	}
	
	func itemsDownloaded(items: NSArray) {
		feedItems = items
		self.table.reloadData()
	}	/////LOAD ON START UP
	func load() -> Void{
		let store = tabBarController?.viewControllers![0] as! StoreLocationController//this allows me to access the previous OBJECT data
		let index = store.store_array_index
		let storeOBJ:Store = store.feedItems[index] as! Store
		storeID=storeOBJ.getID()
		////////UNWRAPP VARIABLE
		progressBar.startAnimating()
		let nib = UINib(nibName: "StylistTableViewCell",bundle: nil);
		self.table.registerNib(nib, forCellReuseIdentifier: self.cellID)
		self.table.dataSource=self
		self.table.delegate = self
		let sm = StylistModel()
		sm.delegate=self
		sm.downloadItems(storeID)///the id
		table.hidden=false
		progressBar.stopAnimating()
		
		
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		load()
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return feedItems.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
		
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! StylistTableViewCell
		let stylist=self.feedItems[indexPath.row] as! Stylist
		//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), {
		
		////
		let request = NSMutableURLRequest(URL: NSURL(string:"http://www.acbasoftware.com/picture.php")!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
		
		let code=("acbapicturesacba").sha1()
		let store_id=self.storeID
		
		let stylist_id=stylist.getID()
		let postString = "stylist="+String(stylist_id)+"&store="+String(store_id)+"&code="+code
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		///////////////////////set post request
		
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			guard error == nil && data != nil else {
				//self.showError()// check for fundamental networking error
				return
			}
			if let HTTPResponse = response as? NSHTTPURLResponse {
				let statusCode = HTTPResponse.statusCode
				
				if (statusCode == 200) {
					
					if let image = UIImage(data: data!) {
						
						dispatch_async(dispatch_get_main_queue(), { //dispatch
							cell.imageView!.image = image
							
							cell.name.text="Stylist: "+stylist.getName()
							cell.people_waiting.text="Waiting: "+String(stylist.getWait())
							cell.approx_wait_time.text="Approximate wait: "+stylist.approxWait(stylist.getWait())
							
							if(stylist.isAvailable()){
						
								cell.reserve_time_estimate.text="ReserveMe: "+stylist.getReserveTime()
							}else{
								cell.reserve_time_estimate.text="NOT AVAILABLE TODAY"
							}
							
						})////dispatch
						
					}else{
						print("something bad...")
						
					}
					
				}else{
				print("Error connecting...")
				}
			}
			//})//dispatch
		}
		task.resume()
		
		
		return cell
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let stylist:Stylist = feedItems[indexPath.row] as! Stylist
		
		if(stylist.available==0){
			//print("not available")
		return
		}
			///process credit card
		var alert = UIAlertView()
		alert.delegate = self
		alert.title = "Selected Row"
		alert.message = "You selected row \(indexPath.row)"
		alert.addButtonWithTitle("OK")
		alert.show()
		
	}
	
	
	

}
