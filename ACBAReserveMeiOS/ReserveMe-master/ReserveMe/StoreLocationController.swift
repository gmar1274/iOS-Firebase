//
//  StoreLocationController.swift
//  ReserveMe
//
//  Created by user on 8/15/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class StoreLocationController:UIViewController, UITableViewDataSource, UITableViewDelegate, StoreModelProtocal {
	@IBOutlet weak var table: UITableView!
	@IBOutlet weak var progressBar: UIActivityIndicatorView!
	let cellId="cell"
	var store_id=0
	var store_array_index=0
	//var store_map = Dictionary<Int,Store>()//store id dtore object
	var load=false
	var feedItems: NSArray = NSArray()
	
	override func viewDidAppear(animated: Bool) {
		//super.viewDidAppear(animated)
		if(load==false){
			onLoad()
		}
	}
	override func viewDidDisappear(animated: Bool) {
		load=false
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		load=true
		
		onLoad()
		
		
		
	}
	func onLoad(){
		progressBar.startAnimating()
		let nib = UINib(nibName: "TableViewCell",bundle: nil);
		self.table.registerNib(nib, forCellReuseIdentifier: self.cellId)
		self.table.dataSource=self
		self.table.delegate = self
		let sm = StoreModel()
		sm.delegate = self
		sm.downloadItems()
		table.hidden=false
		progressBar.stopAnimating()
		
	}
	func itemsDownloaded(items: NSArray) {
		
		feedItems = items
		self.table.reloadData()
	}	/*func post() -> Void{
	let web="http://www.acbasoftware.com/store.php"
	let request = NSMutableURLRequest(URL: NSURL(string: web)!)
	let session = NSURLSession.sharedSession()
	request.HTTPMethod = "POST"
	
	let code=("acbastorelistacba").sha1()
	let postString = "&store="+code
	request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
	let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
	guard error == nil && data != nil else {
	self.showError()// check for fundamental networking error
	return
	}
	if let HTTPResponse = response as? NSHTTPURLResponse {
	let statusCode = HTTPResponse.statusCode
	
	//let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
	//print(responseString)//server response
	if (statusCode == 200) {
	///good connection
	}else{
	self.showError()
	}
	}
	do {
	
	// Parse the JSON
	let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
	
	let value = jsonDictionary["store"] as! NSArray
	for(var i=0; i<value.count; ++i){
	let name:String=(value[i]["Store"] as? String)!
	let address:String=(value[i]["Address"] as? String)!
	let citystate:String=(value[i]["CityState"] as? String)!
	let id:String=(value[i]["id"] as? String)!
	
	let store:Store=Store(name:name,address:address,citystate:citystate,id:Int(id)!)
	self.store_map[Int(id)!]=store
	
	
	//print(value[i])
	//print(value[i]["id"])
	
	}
	
	} catch {
	self.showError()
	}			/////
	
	}
	task.resume()
	
	}
	*/
	
	/*func populate()->Void{
	//dispatch_async(dispatch_get_main_queue()) { [unowned self] in
	
	//progressBar.stopAnimating()
	self.progressBar.hidden=true
	let nib = UINib(nibName: "TableViewCell",bundle: nil);
	self.table.registerNib(nib, forCellReuseIdentifier: self.cellId)
	
	self.table.dataSource=self
	self.table.delegate = self
	print(self)
	print("AYPY:: "+String(self.store_map.count))
	//}
	}
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
 // UITableViewDataSource Functions
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return feedItems.count///return store_map.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TableViewCell
		let store:Store = feedItems[indexPath.row] as! Store///let store:Store = self.store_map[indexPath.row]!
		
		
		cell.store.text="Store: "+store.getName()
		cell.address.text="Address: "+store.getAddress()
		cell.citystate.text=store.getCityState()
		//myArray[indexPath.row]
		
		return cell
	}
	
	
	// UITableViewDelegate Functions
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 100
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let store:Store=feedItems[indexPath.row] as! Store
		store_id=store.getID()
		store_array_index=indexPath.row
		let alert = UIAlertView()
		alert.delegate = self
		alert.title = "Selected Row"
		alert.message = "You selected row \(indexPath.row) and ID: \(store_id)"
		alert.addButtonWithTitle("OK")
		alert.show()
		tabBarController?.selectedIndex=1
	}
	func showError() {
		dispatch_async(dispatch_get_main_queue()) { [unowned self] in
			self.alert()
		}
	}
	func alert(){
		let alertView = UIAlertController(title: "Network error", message: "", preferredStyle: .Alert)
		alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
		presentViewController(alertView, animated: true, completion: nil)
		
	}
	
	func getJSON(urlToRequest: String) -> NSData{
		return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
	}
	
	func parseJSON(inputData: NSData) -> NSDictionary{
		do{
			let boardsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
			return boardsDictionary
		}catch{
			return Dictionary<String,String>()
		}
	}
	
}

