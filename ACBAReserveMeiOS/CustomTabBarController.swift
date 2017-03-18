//
//  CustomTabBarController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/3/17.
//  Copyright © 2017 user. All rights reserved.
//EMPOLYEE TAB CONTROLLER SETTINGS ACCOUNT
//

import UIKit

class CustomTabBarController: UITabBarController {

	var employee:FirebaseEmployee?
	var sty_id:String = ""
	var store_id:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
		if employee?.type != "OWNER" {
			self.viewControllers?.remove(at: 2)///remove the third tab...STORE SETTINGS only for owner
		}
		//print("Firebase in CustomTab...: \(employee?.store_number)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
