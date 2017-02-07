//
//  UserSettingsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/6/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	//var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if(StylistViewController.stylist != nil){
		self.imageView.image = UIImage(data:(StylistViewController.stylist?.imageArray)!)
		self.nameLabel.text = StylistViewController.stylist?.name.uppercased()
		}
		
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
