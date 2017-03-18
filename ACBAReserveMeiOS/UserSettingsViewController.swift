//
//  UserSettingsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 1/6/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import Firebase
class UserSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var nameLabel: UILabel!
	var emp:FirebaseEmployee!
	
	@IBOutlet var phone_label: UILabel!
	
	@IBOutlet var chooseBuuton: UIButton!
	var imagePicker = UIImagePickerController()
	
	
	@IBOutlet var updatepasswordTextField: UITextField!
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
		textField.resignFirstResponder()
		return true
	}
	@IBAction func updatePassword(_ sender: Any) {
		if (self.updatepasswordTextField.text?.characters.count)! <= 5{//password cant be less than 6
				self.customAlertDialog(title: "Error", msg: "Password needs to be at least 6 characters long.")
			return
		}
		let new_pass = self.updatepasswordTextField.text?.sha1()
		let ref = FIRDatabase.database().reference().child("employees/\(self.emp.id!)/app_password")
		ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
			
			if let pass = currentData.value as? String{
				currentData.value = new_pass
				return FIRTransactionResult.success(withValue: currentData)
			}
			return FIRTransactionResult.success(withValue: currentData)
		}){ (error, committed, snapshot) in
			if let error = error {
				print(error.localizedDescription)
			}else{
				self.customAlertDialog(title: "Success", msg: "Password is now updated.")
				
			}
			
			
		}
	}
	func customAlertDialog(title:String, msg:String) -> UIAlertController{
		let a = UIAlertController(title:title,message:msg, preferredStyle: .alert)
		let k = UIAlertAction(title: "OK", style: .default)
		a.addAction(k)
		self.present(a, animated: true, completion: nil)
		return a
	}
	
	@IBAction func password_update(_ sender: UITextField, forEvent event: UIEvent) {
		let new_pass = sender.text!.sha1()
		let ref = FIRDatabase.database().reference().child("employees/\(self.emp.id!)/app_password")
		ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
			
			if let pass = currentData.value as? String{
				currentData.value = new_pass
				return FIRTransactionResult.success(withValue: currentData)
			}
			return FIRTransactionResult.success(withValue: currentData)
		}){ (error, committed, snapshot) in
			if let error = error {
				print(error.localizedDescription)
			}else{
				
				
				let a = UIAlertController(title: "Success", message: "Password is now updated.", preferredStyle: .alert)
				let k = UIAlertAction(title: "OK", style: .default)
				a.addAction(k)
				self.present(a, animated: true, completion: nil)
				
				
			}
			
			
		}
		
	}
	func imagePickerControllerDidCancel(picker: UIImagePickerController)
	{
		print("picker cancel.")
	}
	//var user_data:NSData?
	//var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
		self.imagePicker.delegate = self
		self.updatepasswordTextField.delegate = self
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
		
        // Do any additional setup after loading the view.////LOADED IMAGE
		let path = "stylists/\(self.emp.store_number!.description)/\(self.emp.id!.description)"
		let ref_avail = FIRDatabase.database().reference().child(path+"/available")
		ref_avail.observe(FIRDataEventType.value, with: {snap in
			guard let avail = snap.value as? Bool else{
				self.statusLabel.text = "Not Active"
				print("err \(snap)")
				return
			}
			self.switchStatus.isOn = avail
			self.determineTextForSwitch(sender: self.switchStatus)
		
		})///end avail
		
		FIRDatabase.database().reference().child(path+"/phone").observe(FIRDataEventType.value, with: {snap in
			guard let phone = snap.value as? String else{
				self.phone_label.text = "N/A"
				print("err \(snap)")
				return
			}
			self.phone_label.text = Utils.formatPhone(phone:phone)
		})
		
		
		
    }
	@IBAction func resetStoreTicket(_ sender: Any) {
		var alert = UIAlertController(title: "Reset shop's ticket counter to 1?", message: "This action cannot be reversed.", preferredStyle: .alert)
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
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
			print("Button capture")
			
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
			imagePicker.allowsEditing = false
			
			self.present(imagePicker, animated: true, completion: nil)
		}
		
	}
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject] ){
		self.dismiss(animated: true, completion: { () -> Void in
			
		})
		
		self.imageView.image = image
	}
	
	
	
	
	
	
	////settings::
	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var switchStatus: UISwitch!
	
	@IBAction func statusChanged(_ sender: UISwitch) {
		statusRequest(sender:sender)
	}
	func statusRequest(sender : UISwitch){
		let alert = self.displayLoadingDialog(title: "Updating Status", msg: "Please wait...")
		self.present(alert, animated: true, completion: nil)
		let path = "stylists/\(self.emp.store_number!.description)/\(self.emp.id!.description)/available"
		let ref = FIRDatabase.database().reference().child(path)
		ref.setValue(sender.isOn){(err , ref) in
			alert.dismiss(animated: true, completion: {
				if err != nil{//error
					self.displayMessage(title: "Error.", msg: "Something went wrong. No data was updated.")
				}else{//success
					self.determineTextForSwitch(sender:sender)
					self.displayMessage(title: "Success", msg: "Status updated!")
				}
			})//alert handler
			
		}
	}
	func determineTextForSwitch(sender:UISwitch){
		if sender.isOn {
			self.statusLabel.text = "Active"
		}else{
			self.statusLabel.text = "Not Active"
		}
	}
	

	@IBAction func phontTFChanged(_ sender: UITextField) {
		if sender.text?.characters.count == 10{
			//print("10 lentgh detected!!")
			self.updatePhone(phone:sender.text!)
		}//else{
		//	print("TEXT: \(sender.text?.description)")
		//}
		
	}
	/***APPAREANTLY FIREBASE ONLY ALLOWS STRING AS an ANY object only. SO CAST A STRING TO ANY.
*/
	func updatePhone(phone : String){
		var alert = UIAlertController(title: "Update phone?", message: "Click to set your preferred contact number to '\(phone.description)'.", preferredStyle: .alert)
		let act = UIAlertAction(title: "Update", style: .default, handler: { ui in
			let path = "stylists/\(self.emp.store_number!.description)/\(self.emp.id!.description)/phone"
			let ref = FIRDatabase.database().reference().child(path)
			let loading = self.displayLoadingDialog(title: "Updating", msg: "Please wait...")
			let obj = phone as! Any
			ref.setValue(obj){ (err,fir) in
				if err != nil{
					//print("errr....")
					self.displayMessage(title: "Error", msg: "Something went wrong. No data has been changed...")
				}else{
					//print("here don ok...")
					//loading.dismiss(animated: true, completion: {
					self.displayMessage(title:"Phone updated!",msg:"Phone number changed.")//				})
				}
			}//end setValue
			
		})//end action
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancel)
		alert.addAction(act)
		self.present(alert, animated: true, completion: nil)
		
	}
	func displayMessage(title:String, msg:String){
		var alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alert.addAction(action)
		self.present(alert, animated: true, completion: nil)
	}
	//////////////LOADING DIALOG
	
	func displayLoadingDialog(title:String, msg:String) -> UIAlertController{
		var alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		alert.view.tintColor = UIColor.black
		
		let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingIndicator.startAnimating();
		
		alert.view.addSubview(loadingIndicator)
		return alert
		//present(alert, animated: true, completion: nil)//display seraching
	}
	

}
