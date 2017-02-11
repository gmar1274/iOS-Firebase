//
//  MainTabControllerViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 11/20/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit

class MainTabControllerViewController: UITabBarController {
	
	var pastTickets:[FirebaseTicket]=[]
	var store:FirebaseStore?
    override func viewDidLoad() {
        super.viewDidLoad()
		        // Do any additional setup after loading the view.
    }
	public func setCurrentStore(store:FirebaseStore){
		self.store = store
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
