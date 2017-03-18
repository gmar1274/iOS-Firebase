//
//  PastTicketsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PastTicketsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate{

	var tickets:[FirebaseTicket] = []
	@IBOutlet var adBanner: GADBannerView!
	
	@IBOutlet var ticketsTableView: UITableView!
	
	
	func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
		self.adBanner.isHidden = false
	}
	func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
		self.adBanner.isHidden = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.adBanner.isHidden = true
		self.adBanner.adSize = kGADAdSizeSmartBannerPortrait
		self.adBanner.delegate = self
		self.adBanner.rootViewController = self
		//App ID: ca-app-pub-9309556355508377~2611344846
		//Ad unit ID: ca-app-pub-9309556355508377/3793700042
		self.adBanner.adUnitID = "ca-app-pub-9309556355508377/3793700042"
		var request = GADRequest()
		self.adBanner.load(request)
		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	override func viewWillAppear(_ animated: Bool){
		//super.viewWillAppear(animated)
		let tc = self.tabBarController as! MainTabControllerViewController
		self.tickets = tc.pastTickets
		//print("tickets...\(tickets) \nvs\n\(tc.pastTickets)")
		self.ticketsTableView.delegate = self
		self.ticketsTableView.dataSource = self
		self.ticketsTableView.reloadData()
		
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tickets.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = self.ticketsTableView.dequeueReusableCell(withIdentifier: "pt_viewcell") as! PastTicketHistoryTableViewCell
		let t = self.tickets[indexPath.row]
		cell.ticket_number_label.text = t.unique_id.description
		cell.stylist_label.text = t.stylist.uppercased()
		cell.readyBy_label.text = t.readyBy!
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
}
