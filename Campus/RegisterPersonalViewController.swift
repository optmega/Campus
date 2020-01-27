//
//  RegisterPersonalViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/4/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import ViewDeck

import SwiftyJSON

class RegisterPersonalViewController: UIViewController
{
	private static let registerToTermsSegueId = "registerToTerms"
	
	// MARK: - Outlets
	
	@IBOutlet var scrollView: UIScrollView!

	@IBOutlet var firstNameField: IndentedTextField!
	@IBOutlet var lastNameField: IndentedTextField!
	@IBOutlet var emailField: IndentedTextField!
	@IBOutlet var passwordField: IndentedTextField!
	@IBOutlet var passwordConfirmationField: IndentedTextField!
	
	@IBOutlet var nextButton: UIButton!
	
	
	// MARK: - Actions
	
	@IBAction func nextPressed(sender: UIButton)
	{
		lastNameField.layer.borderColor             = UIColor.lightGrayColor().CGColor
		firstNameField.layer.borderColor            = UIColor.lightGrayColor().CGColor
		emailField.layer.borderColor                = UIColor.lightGrayColor().CGColor
		passwordField.layer.borderColor             = UIColor.lightGrayColor().CGColor
		passwordConfirmationField.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		guard let firstName = firstNameField.text where firstName != ""
			else
		{
			firstNameField.layer.borderColor = UIColor.redColor().CGColor
			
			return
		}
		
		guard let lastName = lastNameField.text where lastName != ""
			else
		{
			lastNameField.layer.borderColor = UIColor.redColor().CGColor
			
			return
		}
		
		guard let email = emailField.text where email.isEmail
			else
		{
			emailField.layer.borderColor = UIColor.redColor().CGColor
			
			return
		}
		
		guard let password = passwordField.text,
			passwordConfirm = passwordConfirmationField.text
			where password != "" &&
				password == passwordConfirm
			else
		{
			passwordField.layer.borderColor = UIColor.redColor().CGColor
			
			passwordConfirmationField.layer.borderColor = UIColor.redColor().CGColor
			
			return
		}
		
		let user = CampusUser.currentUser
		user.email = emailField.text!
		user.firstName = firstNameField.text!
		user.lastName =  lastNameField.text!
		
		self.performSegueWithIdentifier(RegisterPersonalViewController.registerToTermsSegueId, sender: self)
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationController?.navigationBarHidden = false
		self.navigationItem.title = "Sign Up"
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen

        firstNameField.layer.borderColor = UIColor.lightGrayColor().CGColor
		firstNameField.layer.borderWidth = 1
		
		lastNameField.layer.borderColor = UIColor.lightGrayColor().CGColor
		lastNameField.layer.borderWidth = 1
		
		emailField.layer.borderColor = UIColor.lightGrayColor().CGColor
		emailField.layer.borderWidth = 1
		
		passwordField.layer.borderColor = UIColor.lightGrayColor().CGColor
		passwordField.layer.borderWidth = 1
		
		passwordConfirmationField.layer.borderColor = UIColor.lightGrayColor().CGColor
		passwordConfirmationField.layer.borderWidth = 1

		nextButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
		
		self.scrollView.contentOffset.y = 150
    }

	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		firstNameField.layer.cornerRadius = firstNameField.frame.size.height / 2
		firstNameField.horizontalPadding = firstNameField.frame.size.height / 2
		
		lastNameField.layer.cornerRadius = lastNameField.frame.size.height / 2
		lastNameField.horizontalPadding = lastNameField.frame.size.height / 2
		
		emailField.layer.cornerRadius = emailField.frame.size.height / 2
		emailField.horizontalPadding = emailField.frame.size.height / 2
		
		passwordField.layer.cornerRadius = passwordField.frame.size.height / 2
		passwordField.horizontalPadding = passwordField.frame.size.height / 2
		
		passwordConfirmationField.layer.cornerRadius = passwordConfirmationField.frame.size.height / 2
		passwordConfirmationField.horizontalPadding = passwordConfirmationField.frame.size.height / 2
		
		nextButton.layer.cornerRadius = nextButton.frame.size.height / 2
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? TermsOfUseViewController
			where segueId == RegisterPersonalViewController.registerToTermsSegueId
		{
			destVC.password = passwordField.text!
		}

	}

}
