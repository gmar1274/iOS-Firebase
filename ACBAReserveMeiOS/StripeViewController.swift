//
//  StripeViewController.swift
//  ACBAReserveMeiOS
//
//  Created by user on 12/27/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit
import Stripe
class StripeViewController: UIViewController, STPPaymentContextDelegate {
//var myAPIClient = STPPaymentConfiguration.init()
	var paymentContext:STPPaymentContext?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//let paymentField = STPPaymentCardTextField(frame: CGRect(x: 10, y: 10, width:300, height: 44))
		//paymentField.delegate = self
		//self.view.addSubview(paymentField)
	}
		init() {
			// Here, MyAPIAdapter is your class that implements STPBackendAPIAdapter (see above)
			self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient())
			super.init(nibName: nil, bundle: nil)
			self.paymentContext?.delegate = self
			self.paymentContext?.hostViewController = self
			self.paymentContext?.paymentAmount = 5000 // This is in cents, i.e. $50 USD
		}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: STPPaymentCardTextFieldDelegate
	
	func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
		print("Card number: \(textField.cardParams.number) Exp Month: \(textField.cardParams.expMonth) Exp Year: \(textField.cardParams.expYear) CVC: \(textField.cardParams.cvc)")
		//self.buyButton.enabled = textField.isValid
	}
	
	
	func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
		//self.activityIndicator.animating = paymentContext.loading
		//self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
		//self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
		//self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
	}
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didCreatePaymentResult paymentResult: STPPaymentResult,
	                    completion: @escaping STPErrorBlock) {
		
  /**myAPIClient.createCharge(paymentResult.source.stripeID, completion: { (error: Error?) in
	if let error = error {
		completion(error)
	} else {
		completion(nil)
	}
})*/
	}//end metod
	
	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFinishWith status: STPPaymentStatus,
	                    error: Error?) {
		
		switch status {
		case .error: break
			//self.showError(error)
		case .success: break
			//self.showReceipt()
		case .userCancellation:
			return // Do nothing
		}
	}

	func paymentContext(_ paymentContext: STPPaymentContext,
	                    didFailToLoadWithError error: Error) {
		//self.navigationController?.popViewController(animated: true)
		// Show the error to your user, etc.
	}}
