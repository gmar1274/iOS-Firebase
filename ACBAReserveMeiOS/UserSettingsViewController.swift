//
//  UserSettingsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/6/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import Firebase
class UserSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	var emp:FirebaseEmployee!
	//var user_data:NSData?
	//var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
		let ct = self.tabBarController as! CustomTabBarController
		 emp = ct.employee!
		let ref = FIRStorage.storage().reference().child("\(emp.store_phone!)/images/stylists/\(emp.id!)")
		ref.data(withMaxSize: 10*1024*1024, completion: { data, error in//10 mb
			if let error = error{
				print("file error download exit...err: \(error)")
				
			}else{
				print("image success...")
				self.imageView.image = UIImage(data: data!)
			}
		})//end statement
		self.nameLabel.text = emp.name!.uppercased()
		
        // Do any additional setup after loading the view.
    }
	@IBAction func resetStoreTicket(_ sender: Any) {
		var alert = UIAlertController(title: "Reset shop's ticket to 0?", message: "This action cannot be reversed.", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel)
		let ok = UIAlertAction(title: "YES", style: .default){
			action in
			self.resetStoreTicket()
		}
		alert.addAction(cancel)
		alert.addAction(ok)
		self.present(alert, animated: true, completion: nil)
	}
	func resetStoreTicket(){
		
		let ref = FIRDatabase.database().reference().child("user/\(self.emp.store_number!)/current_ticket")
	ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
			
			//print("\n\nSNAPSHOT:: \(currentData.value)\n\n")
			if currentData.childrenCount > 0 {
				currentData.value = 0
				
				return FIRTransactionResult.success(withValue: currentData)
			}//end if somethings there NOT NILL
			else{//first ticket
			currentData.value = 0
			}
			return FIRTransactionResult.success(withValue: currentData)
			}){ (error, committed, snapshot) in
				if let error = error {
					print(error.localizedDescription)
				}else{
					
					
					let a = UIAlertController(title: "Tickets have been restarted.", message: "Current ticket is now 1.", preferredStyle: .alert)
					let k = UIAlertAction(title: "OK", style: .default)
					a.addAction(k)
					self.present(a, animated: true, completion: nil)
					
					
				}
			
			
		}
		
			
	}

	@IBAction func upload(_ sender: Any) {//change picture
		print("here")
		self.openPhotoLibrary()
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func openPhotoLibrary(){
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
			
			var imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
			imagePicker.allowsEditing = true
			 OperationQueue.main.addOperation {
			
			self.present(imagePicker, animated: true, completion: nil)
			}
		}
		
	}
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
		self.dismiss(animated: true, completion: { () -> Void in
			
		})
		
		imageView.image = image
		
	}



}
