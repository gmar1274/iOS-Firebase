//
//  ViewController.swift
//  ReserveMe
//
//  Created by user on 8/12/16.
//  Copyright © 2016 user. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var username_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
		title="ACBA: ReserveMe"
		
        // Do any additional setup after loading the view, typically from a nib.
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(sender: UIButton) {
        
        post()
    }
    

    @IBAction func register(sender: UIButton) {
		
		
    }
    @IBAction func continueAsGuest(sender: UIButton) {
    }
   
    
    func post()->Void{
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.acbasoftware.com/login/login.php")!)
		let session = NSURLSession.sharedSession()
		request.HTTPMethod = "POST"
        let username=self.username_tf.text
        let password=self.password_tf.text
		if(isEmpty(username!,pass:password!)){
			alert()
		}else{
			let code=("acbaloginacba").sha1()
			let postString = "username="+username!+"&password="+(password?.sha1())!+"&code="+code
		        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                return
            }
			if let HTTPResponse = response as? NSHTTPURLResponse {
				let statusCode = HTTPResponse.statusCode
				
				let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
				//server response
				if (statusCode == 200 && responseString != nil && (responseString?.containsString("access granted"))!) {
					
					self.goToMain()
				}else{
					self.showError()
				}
			}
		
        }
        task.resume()
		}
    }
	func isEmpty(user:NSString,pass:NSString) -> Bool  {
		if(user.length==0 || !user.containsString("@") || !user.containsString(".")){
			username_tf.layer.borderColor=UIColor.redColor().CGColor;
			username_tf.layer.borderWidth = 3.0;
			return true
		}
		if(pass.length<5){
			password_tf.layer.borderColor=UIColor.redColor().CGColor;
			password_tf.layer.borderWidth = 3.0;
			return true
		}
		return false
	}
	func alert(){
	let alertView = UIAlertController(title: "Login error", message: "Username or password is incorrect", preferredStyle: .Alert)
	alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
	presentViewController(alertView, animated: true, completion: nil)
		
	}
	func goToMain() {
	dispatch_async(dispatch_get_main_queue()) { [unowned self] in
			self.performSegueWithIdentifier("guest_id", sender:nil)
		}
	}
	func showError() {
	dispatch_async(dispatch_get_main_queue()) { [unowned self] in
			self.alert()
		}
	}
}