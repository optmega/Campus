//
//  NewGroupPostViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import M13Checkbox

class NewGroupPostViewController: UIViewController
{
	// MARK: - Properties
	
	var group: CampusGroup!
	var accessLevel: CampusGroup.UserAccessLevel!
	
	private var postVisibility = CampusGroupPost.PostVisibility.Public
	// MARK: - Outlets
	
	@IBOutlet var postTitle: IndentedTextField!
	@IBOutlet var postText: UITextView!
	@IBOutlet var showTimePickerCheckbox: M13Checkbox!
	@IBOutlet var timePicker: UIDatePicker!
	@IBOutlet var timePickerHiddenConstraint: NSLayoutConstraint!

	@IBOutlet var adminsButton: UIButton!
	@IBOutlet var membersButton: UIButton!
	@IBOutlet var publicButton: UIButton!
	
	@IBOutlet var submitButton: UIButton!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Actions
	
	@IBAction func showTimePickerChanged(sender: M13Checkbox)
	{
		if sender.checkState == M13CheckboxStateChecked
		{
			timePickerHiddenConstraint.active = false
		} else
		{
			timePickerHiddenConstraint.active = true
		}
		
		UIView.animateWithDuration(Constants.Values.AnimationDurationShort) {
			self.view.layoutIfNeeded()
		}
	}
	
	@IBAction func adminsPressed(sender: UIButton)
	{
		postVisibility = CampusGroupPost.PostVisibility.Admins
		
		adminsButton.backgroundColor = Constants.Colors.Purple
		membersButton.backgroundColor = UIColor.lightGrayColor()
		publicButton.backgroundColor = UIColor.lightGrayColor()
	}
	
	@IBAction func membersPressed(sender: UIButton)
	{
		postVisibility = CampusGroupPost.PostVisibility.Members
		
		adminsButton.backgroundColor = UIColor.lightGrayColor()
		membersButton.backgroundColor = Constants.Colors.Purple
		publicButton.backgroundColor = UIColor.lightGrayColor()
	}
	
	@IBAction func publicPressed(sender: UIButton)
	{
		postVisibility = CampusGroupPost.PostVisibility.Public
		
		adminsButton.backgroundColor = UIColor.lightGrayColor()
		membersButton.backgroundColor = UIColor.lightGrayColor()
		publicButton.backgroundColor = Constants.Colors.Purple
	}
	
	@IBAction func submitPressed(sender: UIButton)
	{
		guard let title = postTitle.text where title != ""
			else
		{
			postTitle.layer.borderColor = UIColor.redColor().CGColor
			postTitle.layer.borderWidth = 1
			log.error("Post needs title")
			
			return
		}
		
		postTitle.layer.borderWidth = 0
		
		let post = CampusGroupPost(
			id: -1,
			title: title,
			text: postText.text,
			postDate: NSDate(),
			visibility: postVisibility,
			user: CampusUser.currentUser,
			group: group)
		
		if showTimePickerCheckbox.checkState == M13CheckboxStateChecked
		{
			post.eventDate = timePicker.date
		}
		
		activityIndicator.startAnimating()
		
		CampusGroupPostRequest.createGroupPost(post,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.navigationController?.popViewControllerAnimated(true)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				if case .StatusCode(let statusCode, let message) = error where statusCode == 422
				{
					let alertController = UIAlertController(title: "Could not create new post", message: message, preferredStyle: .Alert)
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
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		// TODO: Check user role and disable posting scope (members > no admin posts, etc)
		
		postText.layer.borderWidth = 1
		postText.layer.borderColor = Constants.Colors.DefaultTextFieldBorderColor.CGColor
		
		showTimePickerCheckbox.uncheckedColor = UIColor.whiteColor()
		showTimePickerCheckbox.tintColor = UIColor.whiteColor()
		showTimePickerCheckbox.checkColor = Constants.Colors.Purple
		showTimePickerCheckbox.strokeColor = Constants.Colors.BrightPurple
		
		showTimePickerCheckbox.checkAlignment = M13CheckboxAlignmentLeft
		
		switch accessLevel!
		{
			case .Member:
				self.adminsButton.removeFromSuperview()
			default: ()
		}
    }
	
	override func viewDidLayoutSubviews()
	{
		postTitle.horizontalPadding = postTitle.frame.size.height / 2
		
		adminsButton.layer.cornerRadius = adminsButton.frame.size.height / 2
		membersButton.layer.cornerRadius = membersButton.frame.size.height / 2
		publicButton.layer.cornerRadius = publicButton.frame.size.height / 2
		
		submitButton.layer.cornerRadius = submitButton.frame.size.height / 2
	}

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
