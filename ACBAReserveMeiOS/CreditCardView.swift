//
//  CreditCardView.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/23/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit
import Stripe
/***
This class will represent the View of making a creditCard transaction
*/

class CreditCardView: UIViewController, STPPaymentContextDelegate {
	
	
	@IBOutlet var header: UILabel!
	@IBOutlet var name: UITextField!
	
	@IBOutlet var credit_card: UITextField!
	
	@IBOutlet var phone: UITextField!
	
	@IBOutlet var expr_month: UITextField!

	@IBOutlet var expr_year: UITextField!
	
	@IBOutlet var ccv: UITextField!
	
	
	@IBOutlet var details: UILabel!//like for Stylist: xyx \n service:
	
	@IBOutlet var price: UILabel!
	
	let phone_limit = 10 //phone, CCN, EXPR_MNTH, EXPR_YR, CCV
	let ccn_limit=25
	let date_limit=2
	let ccv_limit = 4
	let name_limit = 200
	
	var store:FirebaseStore?
	var stylist:FirebaseStylist?
	//////
	var paymentContext:STPPaymentContext
	var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

	
	@IBAction func CANCEL(_ sender: AnyObject) {
		
		dismiss(animated: true, completion: nil)
	
	}
	
	@IBAction func RESERVE(_ sender: AnyObject) {
			self.paymentContext.requestPayment()
	}
	
	
	func updateFromAppointment(av:AppointmentViewController){
		self.header.text = "Stylist: \(av.stylistLabel.text!)"
		let string = "Appointment for: \(av.dateLabel.text!) \nTime: \(av.displayCurerntValue())\nService: \(av.serviceLabel.text!)\nPrice: \(av.priceLabel.text!)\nDuration: \(av.durationLabel.text!)"
		
		self.details.lineBreakMode = .byWordWrapping
		self.details.text = string
		self.details.adjustsFontSizeToFitWidth = true
		self.details.sizeToFit()
	}

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	init(){
		self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())
		super.init(nibName:nil, bundle:nil)
		
		self.paymentContext.delegate = self
		self.paymentContext.hostViewController = self
		self.paymentContext.paymentAmount = 5000//in cents
		
	}
	
	
required init(coder aDecoder: NSCoder) {
		self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())
	
	super.init(coder: aDecoder)!
	
}
	
	@IBOutlet var reserve_btn: UIButton!
	override func viewDidLoad() {
		self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())		
		super.viewDidLoad()
		
		
		
		
		self.header.text = "Shop: \(self.store!.name!.uppercased())"
		self.details.text = "Stylist: \(self.stylist!.name!.uppercased())"
		self.paymentContext.delegate = self
		self.paymentContext.hostViewController = self
		self.paymentContext.paymentAmount = 5000//in cents
		
	}
	@IBAction func actionListener(_ sender: UITextField) {
		switch sender {
		case name:
			checkLimit(sender,limit:name_limit)
			break
		case credit_card:
			checkLimit(sender, limit: ccn_limit)
			break
		case phone:
			checkLimit(sender, limit: phone_limit)
			break
		case expr_month:
			checkLimit(sender, limit: date_limit)
			break
		case expr_year:
			checkLimit(sender, limit: date_limit)
			break
		case ccv:
			checkLimit(sender, limit: ccv_limit)
			break
		default:
			break
			
		}
	}
	func checkLimit(_ tf:UITextField, limit:Int)  {
		if (tf.text!.characters.count > limit) {
			tf.deleteBackward()
		}
	}
	///////////deleagte methods
	func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
		if paymentContext.loading{
			self.activityIndicator.startAnimating()
		}else{
			self.activityIndicator.stopAnimating()
		}
		//self.btn_request.enabled = paymentContext.selectedPaymentMethod != nil
		//self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
		//self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
	}
	
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didCreatePaymentResult paymentResult: STPPaymentResult,
	                    completion: @escaping STPErrorBlock) {
		
		PostRequest.createCharge(token:paymentResult.source.stripeID)
	
	}
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFinishWith status: STPPaymentStatus,
	                    error: Error?) {
		
		switch status {
		case .error:
			self.showError(err: error!)
		case .success:
			self.showReceipt()
		case .userCancellation:
			return // Do nothing
		}
	}
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFailToLoadWithError error: Error) {
		
		let alertController = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			// Need to assign to _ because optional binding loses @discardableResult value
			// https://bugs.swift.org/browse/SR-1681
			_ = self.navigationController?.popViewController(animated: true)
		})
		let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
			self.paymentContext.retryLoading()
		})
		alertController.addAction(cancel)
		alertController.addAction(retry)
		self.present(alertController, animated: true, completion: nil)
	}
	
	
	///end delegate methods
	func showError(err:Error){
		
	}
	func showReceipt(){
		
}
}
