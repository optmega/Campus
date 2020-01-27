//
//  ViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/3/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import M13Checkbox
import ViewDeck

class LoginViewController: UIViewController, UITextFieldDelegate
{
	// MARK: - Outlets
	
	@IBOutlet var loginFieldsContainer: UIView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet var emailField: UITextField!
	@IBOutlet var passwordField: UITextField!
	
	@IBOutlet var rememberCheck: M13Checkbox!
	
	@IBOutlet var loginButton: UIButton!
	
	// MARK: - Actions
	
	@IBAction func loginPressed(sender: UIButton)
	{
		guard let email = emailField.text, password = passwordField.text
			else
		{
			return
		}
		
		UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
			self.loginFieldsContainer.alpha = 0
			self.activityIndicator.alpha = 1
			self.activityIndicator.startAnimating()
		}
		
		let rememberMe = rememberCheck.checkState == M13CheckboxStateChecked
		
		LoginHelper.loginWithEmail(email, password: password, rememberMe: rememberMe,
			successHandler: { (user) -> () in
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.loginFieldsContainer.alpha = 1
					self.activityIndicator.alpha = 0
					self.activityIndicator.stopAnimating()
				}
				
				self.loginUser(user)
			},
			failureHandler: { (error) -> () in
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.loginFieldsContainer.alpha = 1
					self.activityIndicator.alpha = 0
					self.activityIndicator.stopAnimating()
				}
				
				//No difference for the user between wrong email/pass and no such user found
				if case .StatusCode(let statusCode, _) = error where statusCode == 401 || statusCode == 404
				{
					LoginHelper.logout() // Delete any stored email and token, as they are invalid
				}
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	@IBAction func rememberChanged(sender: M13Checkbox)
	{
		Settings.User.rememberUser = rememberCheck.checkState == M13CheckboxStateChecked
	}
	
	@IBAction func forgotPassPressed(sender: UIButton)
	{
		guard let email = emailField.text where email.isEmail
			else
		{
			let alertController = UIAlertController(title: "Please, enter a valid email address in the email field.", message: nil, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		activityIndicator.startAnimating()
		CampusPasswordResetRequest.requestResetForEmail(email,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				let alertController = UIAlertController(title: "An email with a password reset link has been sent to your email account", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	@IBAction func unwindToLogin(sender: UIStoryboardSegue)
	{
		if CampusUser.currentUser.id != Int.min
		{
			emailField.text = CampusUser.currentUser.email
		}
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen

		emailField.layer.borderWidth = Constants.Values.FieldsBorderWidth
		emailField.layer.borderColor = Constants.Colors.BrightPurple.CGColor
		emailField.delegate = self
		
		passwordField.layer.borderWidth = Constants.Values.FieldsBorderWidth
		passwordField.layer.borderColor = Constants.Colors.BrightPurple.CGColor
		passwordField.delegate = self
		
		emailField.attributedPlaceholder = NSAttributedString(string: emailField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
		passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
		
		rememberCheck.titleLabel.text = "Remember me"
		rememberCheck.titleLabel.textColor = UIColor.whiteColor()
		rememberCheck.titleLabel.font = UIFont.systemFontOfSize(12)
		
		rememberCheck.uncheckedColor = Constants.Colors.DarkPurple
		rememberCheck.tintColor = Constants.Colors.DarkPurple
		rememberCheck.checkColor = UIColor.whiteColor()
		rememberCheck.strokeColor = Constants.Colors.BrightPurple
		
		rememberCheck.checkAlignment = M13CheckboxAlignmentLeft
		
		if Settings.User.rememberUser == true && LoginHelper.getEmailAndTokenFromKeychain() != nil
		{
			rememberCheck.checkState = M13CheckboxStateChecked
			
			self.loginFieldsContainer.alpha = 0
			self.activityIndicator.alpha = 1
			self.activityIndicator.startAnimating()
			
			LoginHelper.loginWithKeychain(
				successHandler: { (user) -> () in
					self.loginFieldsContainer.alpha = 1
					self.activityIndicator.alpha = 0
					self.activityIndicator.stopAnimating()
					
					self.loginUser(user)
				},
				failureHandler: { (error) -> () in
					self.loginFieldsContainer.alpha = 1
					self.activityIndicator.alpha = 0
					self.activityIndicator.stopAnimating()
					
					//No difference for the user between wrong email/pass and no such user found
					if case .StatusCode(let statusCode, _) = error where statusCode == 401 || statusCode == 404
					{
						LoginHelper.logout() // Delete any stored email and token, as they are invalid
					}
			})
		}
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		self.navigationController?.navigationBarHidden = true
	}
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		emailField.layer.cornerRadius = emailField.frame.size.height / 2
		passwordField.layer.cornerRadius = passwordField.frame.size.height / 2
		
		loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - UITextFieldDelegate
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		return true
	}
	
//	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//	{
//		let otherField = (textField == emailField) ? passwordField : emailField
//		
//		if let otherText = otherField.text where otherText != "" && range.length + range.location > 0
//		{
//			
//			loginButton.enabled = true
//		} else
//		{
//			loginButton.enabled = false
//		}
//		
//		return true
//	}
	
	// MARK: - Private
	private func loginUser(user: CampusUser)
	{
		CampusUser.currentUser = user
		
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		delegate.rootTabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
		
		if user.firstLogin
		{
			let profileEditController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ProfileEditAboutViewController.storyboardId) as! ProfileEditAboutViewController
			
			delegate.rootTabController.selectedIndex = 2
			(delegate.rootTabController.selectedViewController as? UINavigationController)?.pushViewController(profileEditController, animated: false)
			
			let leftMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeftMenuViewController")
			let deckController = IIViewDeckController(centerViewController: delegate.rootTabController, leftViewController: leftMenuController)
			deckController.panningMode = IIViewDeckPanningMode.NoPanning

			profileEditController.navigationItem.leftBarButtonItem = nil
			
			delegate.window?.rootViewController = deckController
		} else
		{
			delegate.rootTabController.selectedIndex = 1
	
			let leftMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeftMenuViewController")
			let deckController = IIViewDeckController(centerViewController: delegate.rootTabController, leftViewController: leftMenuController)
			deckController.panningMode = IIViewDeckPanningMode.NoPanning
	
			delegate.window?.rootViewController = deckController
		}
	}
}

