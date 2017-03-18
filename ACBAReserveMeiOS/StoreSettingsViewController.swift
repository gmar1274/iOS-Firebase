//
//  StoreSettingsViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 3/13/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import Firebase

class StoreSettingsViewController:UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	


	@IBOutlet var store_image_view: UIImageView!
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var chooseBuuton: UIButton!
	var imagePicker = UIImagePickerController()
	
	
	@IBAction func uploadStoreImageFromPhone(_ sender: Any) {
		self.openPhotoLibrary()
	}
	@IBOutlet var store_ticket_price_label: UILabel!
	
	@IBOutlet var update_ticket_price_tf: UITextField!
	
	
	func openPhotoLibrary(){
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
			print("Button capture")
			
			//delegete
			imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
			imagePicker.allowsEditing = false
			
			self.present(imagePicker, animated: true, completion: nil)
		}
		
	}
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]){
		self.dismiss(animated: true, completion: { () -> Void in
			
		})
		
		self.store_image_view.image = image
	}
	
	
	@IBAction func updateNewTicketPrice(_ sender: Any) {
		FIRDatabase.database().reference().child("user/\(emp!.store_number!)/ticket_price").runTransactionBlock({(cd:FIRMutableData) -> FIRTransactionResult in
		
			if var map = cd.value as? AnyObject{
				let price = Double(self.update_ticket_price_tf.text!)
				cd.value = price
				return FIRTransactionResult.success(withValue: cd)
			}else{
				return FIRTransactionResult.success(withValue: cd)
			}
			
		}) { (error, committed, snapshot) in
			if let error = error {
				print(error.localizedDescription)
				let cd = self.customAlertController(title: "Error", msg: "Something went wrong. No data was saved. Contact ACBA for help.")
				self.present(cd, animated: true, completion: nil)
			}else{
				let cd = self.customAlertController(title: "Success", msg: "Ticket price updated!")
				self.present(cd, animated: true, completion: nil)
				print("debug emp added")
			}
			
		}///////////end update
	}
	
	
	
	//ALERT UI CONTROLLER loading
	func customLoadingController(title:String, msg:String) -> UIAlertController {
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		alert.view.tintColor = UIColor.black
		
		let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingIndicator.startAnimating();
		
		alert.view.addSubview(loadingIndicator)
		return alert
	}
	//ALERT UI CONTROLLER loading
	func customAlertController(title:String, msg:String) -> UIAlertController {
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		return alert
	}
	
	
	@IBAction func addStylistToAPP(_ sender: Any) {
		let msg = "Create a new user by entering the email of the stylist. The default password is your shop's phone number: \(emp!.store_phone!). Once submitted your stylist is ready to login and customize their profile!"
		let alertController = UIAlertController(title: "New Stylist", message: msg, preferredStyle: .alert)
		
		let saveAction = UIAlertAction(title: "Create User", style: .default, handler: {
			alert -> Void in
			let name = alertController.textFields![0] as UITextField
			let email = alertController.textFields![1] as UITextField
			///create user
			let user = FirebaseEmployee(emp: self.emp!,name: name.text!,email: email.text!)
			let sty = FirebaseStylist(owner:self.emp!, user:user)
			////loading
			let loading = self.customLoadingController(title: "Creating user", msg: "Please wait...")
			self.present(loading, animated: true, completion: nil)
			let err_msg = "Oops. There's already a stylist with this id. Please pick another username."
			var err = false
			FIRDatabase.database().reference().child("employees").runTransactionBlock(
				{ (currentData: FIRMutableData) -> FIRTransactionResult in
					if var map = currentData.value as? [String : AnyObject]{
						
						if map[user.id!] != nil{
							err = true
							print("err already exists")
						}else{
							map[user.id!] = user.getDictionaryFormat() as AnyObject?
							currentData.value = map
						}
					
					return FIRTransactionResult.success(withValue: currentData)
					}
					else{
						return FIRTransactionResult.success(withValue: currentData)
					}
			}) { (error, committed, snapshot) in
				if let error = error {
					err = true
					print(error.localizedDescription)
				}else{
					print("debug emp added")
				}
				
			}///////////end employees
			FIRDatabase.database().reference().child("stylists/\(user.store_number!)").runTransactionBlock(
				{ (currentData: FIRMutableData) -> FIRTransactionResult in
					if var map = currentData.value as? [String : AnyObject]{
						
						if map[sty.id!] != nil{
							err = true
							print("err sty already exists")
						}else{
							map[sty.id!] = sty.getDictionaryFormat() as AnyObject?
							currentData.value = map
						}
						
					return FIRTransactionResult.success(withValue: currentData)
					}else{
						return FIRTransactionResult.success(withValue: currentData)
					}
			}) { (error, committed, snapshot) in
				if let error = error {
					err = true
					print(error.localizedDescription)
				}else{
					print("Debug sty added")
				}
			}
			
			
			let storageRef = FIRStorage.storage().reference()
			// Data in memory
			let data = Data()
			
			// Create a reference to the file you want to upload
			let riversRef = storageRef.child("\(self.emp!.store_phone!)/images/stylists/\(user.id!)")
			
			// Upload the file to the path "phone/images/sty/id"
			let uploadTask = riversRef.put(data, metadata: nil) { (metadata, error) in
				guard let metadata = metadata else {
					print("ERR in upload")
					// Uh-oh, an error occurred!
					return
				}
				print("upload complete")
				// Metadata contains file metadata such as size, content-type, and download URL.
				//let downloadURL = metadata.downloadURL
			}
			
			/////finished all tasks
			loading.dismiss(animated: true){
				if err {
					let cd = self.customAlertController(title: "Error", msg: err_msg)
					self.present(cd, animated: true, completion: nil)
				}else{
					let cd = self.customAlertController(title: "Success", msg: "Stylist account is now active!")
					self.present(cd, animated: true, completion: nil)
				}
			}
			
			
		})////end action
		
			
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
			(action : UIAlertAction!) -> Void in
			///
		})
		
		alertController.addTextField { (textField : UITextField!) -> Void in
			textField.placeholder = "Stylist's Full Name"
		}
		alertController.addTextField { (textField : UITextField!) -> Void in
			textField.placeholder = "Sylist's email"
		}
		
		alertController.addAction(saveAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
		
		
	}
	
	@IBAction func deleteStylist(_ sender: Any) {
	}
	
	var emp:FirebaseEmployee?
    override func viewDidLoad() {
        super.viewDidLoad()
		self.imagePicker.delegate = self		
		let tab = self.tabBarController as! CustomTabBarController
		self.emp = tab.employee!
		FIRDatabase.database().reference().child("user/\(emp!.store_number!)/ticket_price").observe(FIRDataEventType.value, with: {ds in
			if let tp = ds.value as? Double {
				let nf = NumberFormatter()
				nf.numberStyle = .currency
				self.store_ticket_price_label.text = nf.string(for: tp)
			}else
			{
				self.store_ticket_price_label.text = "$0.00"
			}
		})
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func imagePickerControllerDidCancel(picker: UIImagePickerController)
	{
		print("picker cancel.")
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
