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
	
	//var user_data:NSData?
	//var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
		let ct = self.tabBarController as! CustomTabBarController
		let emp:FirebaseEmployee = ct.employee!
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
