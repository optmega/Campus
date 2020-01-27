//
//  TermsOfUseViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class TermsOfUseViewController: UIViewController
{
	private static let returnToLoginSegueId = "returnToLogin"
	
	// MARK: - Properties
	
	var password: String! // CampusUser does not store password, so the password from the registration screen is passed here
	
	
	// MARK: - Outlets
	
	@IBOutlet var agreeButton: UIButton!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func agreePressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		CampusUserRequests.createNewUser(CampusUser.currentUser,
			password: password,
			passwordConfirmation: password,
			successHandler: { (user) -> () in
				self.activityIndicator.stopAnimating()
				
				let alertController = UIAlertController(title: "Account successfully created", message: "You can now login with your new account", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "Awesome!", style: .Default) { (action) -> Void in
					self.performSegueWithIdentifier(TermsOfUseViewController.returnToLoginSegueId, sender: self)
				}
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				if case .StatusCode(let statusCode, let message) = error where statusCode == 422
				{
					let alertController = UIAlertController(title: "Could not create your account", message: message, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
				} else
				{
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				}
		})
		

	}
	
	
	// MARK: - Lifecycle
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		agreeButton.layer.cornerRadius = agreeButton.frame.size.height / 2
	}
}
