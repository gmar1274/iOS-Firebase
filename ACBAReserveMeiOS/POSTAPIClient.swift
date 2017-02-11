//
//  POSTAPIClient.swift
//  ACBAReserveMeiOS
//
//  Created by user on 2/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Stripe


class POSTAPIClient: NSObject, STPBackendAPIAdapter {
	
	
	
	static let sharedClient = MyAPIClient()
	let session: URLSession
	var baseURLString: String? = nil
	var defaultSource: STPCard? = nil
	var sources: [STPCard] = []
	let chargeURL:String?="http://www.acbasoftware.com/pos/createCharge.php?"//default my server
	
	override init() {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 5
		self.session = URLSession(configuration: configuration)
		super.init()
	}
	
	func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
		if let httpResponse = response as? HTTPURLResponse
			, httpResponse.statusCode != 200 {
			return error ?? NSError.init()//.networkingError(httpResponse.statusCode)
		}
		return error
	}
	
	
	
	/////repeat func
	
	func completeCharge(token: String, amount: Int, name:String, email:String ,completion: @escaping STPErrorBlock) {
		/*guard let baseURLString = chargeURL, let baseURL = URL(string: baseURLString) else {
			let error = NSError(domain: StripeDomain, code: 50, userInfo: [
				NSLocalizedDescriptionKey: "Please set baseURLString to your Heroku URL in CheckoutViewController.swift"
				])
			completion(error)
			return
		}*/
	//
		//print("TOKEN:: \(token)")
		var param:String="credit_code="+("acbacreditacba").sha1()
		param += "&stripeToken=\(token)"
		param += "&amount=\(amount)"
		param += "&name=\(name)"
		param += "&email=\(email)"
		
		let url:URL = URL(string: chargeURL!)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request, completionHandler:{
			
			
			(data, response, error) in
			
			guard let _:Data = data, let _:URLResponse = response, error == nil else {
				return
			}
			do{
				let json = try JSONSerialization.jsonObject(with: data!,options: .allowFragments) as! [String:AnyObject] //[String:AnyObject]
				for obj in json{
					//print("obj:\(obj)")
					let stat = obj.value
					if 	stat as! String == "success"{
						
						print("callback success")
						completion(nil)
						return
					}else{
						let er = NSError()
						completion(er)
						return
					}
				}
				
			}catch {
				print("no json..err")
				completion(error)
				return
			}
		})
		
		task.resume()
	}
	
	
	
	//end
	
	func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
		guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
			let error = NSError(domain: StripeDomain, code: 50, userInfo: [
				NSLocalizedDescriptionKey: "Please set baseURLString to your Heroku URL in CheckoutViewController.swift"
				])
			completion(error)
			return
		}
		let path = "charge"
		//let url = baseURL.appendingPathComponent(path)
		let params: [String: AnyObject] = [
			"source": result.source.stripeID as AnyObject,
			"amount": amount as AnyObject
		]
		
		let url:URL = URL(string: chargeURL!)!
		let session = URLSession.shared
		
		let request = URLRequest(url: url)//.request(url, method: .POST, params: params)
		let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
					completion(error)
					return
				}
				completion(nil)
			}
		}
		task.resume()
	}
	
	@objc func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
		guard let key = Stripe.defaultPublishableKey() , !key.contains("#") else {
			let error = NSError(domain: StripeDomain, code: 50, userInfo: [
				NSLocalizedDescriptionKey: "Please set stripePublishableKey to your account's test publishable key in CheckoutViewController.swift"
				])
			completion(nil, error)
			return
		}
		guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
			// This code is just for demo purposes - in this case, if the example app isn't properly configured, we'll return a fake customer just so the app works.
			let customer = STPCustomer(stripeID: "cus_test", defaultSource: self.defaultSource, sources: self.sources)
			completion(customer, nil)
			return
		}
		let path = "/customer"
		//let url = baseURL.appendingPathComponent(path)
		let url:URL = URL(string: chargeURL!)!
		let session = URLSession.shared
		
		let request = URLRequest(url: url)
		
		
		let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				let deserializer = STPCustomerDeserializer(data: data, urlResponse: urlResponse, error: error)
				if let error = deserializer.error {
					completion(nil, error)
					return
				} else if let customer = deserializer.customer {
					completion(customer, nil)
				}
			}
		}
		task.resume()
	}
	
	@objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
		guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
			if let token = source as? STPToken {
				self.defaultSource = token.card
			}
			completion(nil)
			return
		}
		let path = "/customer/default_source"
		//let url = baseURL.appendingPathComponent(path)
		let params = [
			"source": source.stripeID,
			]
		//let request = URLRequest.request(url, method: .POST, params: params as [String : AnyObject])
		
		let url:URL = URL(string: chargeURL!)!
		let session = URLSession.shared
		
		let request = URLRequest(url: url)
		
		
		let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
					completion(error)
					return
				}
				completion(nil)
			}
		}
		task.resume()
	}
	
	@objc func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
		guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
			if let token = source as? STPToken, let card = token.card {
				self.sources.append(card)
				self.defaultSource = card
			}
			completion(nil)
			return
		}
		/*let path = "/customer/sources"
		let url = baseURL.appendingPathComponent(path)
		let params = [
			"source": source.stripeID,
			]
		var request = URLRequest(url: url)
		*/
		
		var param:String="store="+("acbastorelistacba").sha1()
		//param += "&lat="+String(mvc.location!.coordinate.latitude)
		//param += "&lon="+String(mvc.location!.coordinate.longitude)
		//param += "&radius="+String(mvc.radius)
		
		let url:URL = URL(string: chargeURL!)!
		let session = URLSession.shared
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
		
		request.httpBody = param.data(using: String.Encoding.utf8)
		
		
		
		//let request = URLRequest.request(url, method: .POST, params: params as [String : AnyObject])
		
		
		
		let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
			DispatchQueue.main.async {
				if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
					completion(error)
					return
				}
				completion(nil)
			}
		}
		task.resume()
	}
	
	
	
	
}
