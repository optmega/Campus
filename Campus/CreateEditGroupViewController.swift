//
//  CreateGroupViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class CreateEditGroupViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
	var group: CampusGroup?

	private let imagePicker = UIImagePickerController()
	private let groupDescriptionCharactersLimit = 250
	
	private var pictureChanged = false
	
	
	// MARK: - Outlets
	
	@IBOutlet var groupImage: UIImageView!
	@IBOutlet var nameField: IndentedTextField!
	@IBOutlet var descriptionTextContainer: UIView!
	@IBOutlet var descriptionTextView: UITextView!
	@IBOutlet var descriptionCharactersCountLabel: UILabel!
	
	@IBOutlet var clubTypePicker: UIPickerView!
	@IBOutlet var recognizedTypePicker: UIPickerView!
	
	@IBOutlet var presidentField: UITextField!
	@IBOutlet var executiveField: UITextField!
	@IBOutlet var executive2Field: UITextField!
	@IBOutlet var executive3Field: UITextField!
	
	@IBOutlet var submitButton: UIButton!
	
	@IBOutlet var imageOverLabelConstraint: NSLayoutConstraint!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func changeGroupPicturePressed(sender: UIButton)
	{
		imagePicker.allowsEditing = true
		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func submitPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		
		if group!.id != -1
		{
			editGroup()
		} else
		{
			createNewGroup()
		}
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		imagePicker.delegate = self
		
		descriptionTextView.text = Constants.Strings.ShortDescriptionPlaceholder
		descriptionTextView.textColor = UIColor.lightGrayColor()
		
		if let group = group
		{
			self.navigationItem.title = "Edit group"
			
			descriptionTextView.text = group.description
			nameField.text = group.name
			
			presidentField.text = group.president
			executiveField.text = group.executive
			executive2Field.text = group.executive2
			executive3Field.text = group.executive3
			
			if let groupType = group.groupType
			{
				clubTypePicker.selectRow(CampusGroup.GroupType.All.indexOf(groupType)!, inComponent: 0, animated: false)
			}
			
			if let recognizedType = group.recognizedGroupType
			{
				recognizedTypePicker.selectRow(CampusGroup.SchoolRecognizedGroupType.All.indexOf(recognizedType)!, inComponent: 0, animated: false)
			} else
			{
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.recognizedTypePicker.hidden = true
				}
			}
			
			group.getGroupPictureFromS3 { (image) -> () in
				if let image = image
				{
					self.groupImage.image = image
					self.groupImage.contentMode = .ScaleAspectFill
					self.imageOverLabelConstraint.active = true
				}
			}
		} else
		{
			group = CampusGroup()
			group!.groupType = .SchoolRecognized
			group!.recognizedGroupType = .GreekOrganization
		}
		
		descriptionTextContainer.layer.borderWidth = 1
		descriptionTextContainer.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		nameField.layer.borderWidth = 1
		nameField.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		
		descriptionTextView.delegate = self
		
		textViewDidChange(descriptionTextView)
    }

	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		nameField.layer.cornerRadius = nameField.frame.size.height / 2
		nameField.horizontalPadding = nameField.frame.size.height / 2
		
		submitButton.layer.cornerRadius = submitButton.frame.size.height / 2
	}
	
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	// MARK: - UITextViewDelegate
	
	func textViewDidBeginEditing(textView: UITextView)
	{
		if let text = textView.text where text == Constants.Strings.ShortDescriptionPlaceholder
		{
			textView.text = ""
			textView.textColor = UIColor.blackColor()
		}
		textView.becomeFirstResponder()
	}
	
	func textViewDidEndEditing(textView: UITextView)
	{
		if let text = textView.text where text == ""
		{
			textView.text = Constants.Strings.ShortDescriptionPlaceholder
			textView.textColor = UIColor.lightGrayColor()
		}
		textView.resignFirstResponder()
	}
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
	{
		let currentCharacterCount = textView.text?.characters.count ?? 0
		
		if (range.length + range.location > currentCharacterCount)
		{
			return false
		}
		
		let newLength = currentCharacterCount + text.characters.count - range.length
		
		return newLength <= groupDescriptionCharactersLimit
	}
	
	func textViewDidChange(textView: UITextView)
	{
		if textView.text.characters.count > groupDescriptionCharactersLimit
		{
			textView.text = textView.text.substringToIndex(textView.text.startIndex.advancedBy(groupDescriptionCharactersLimit))
		}
		
		descriptionCharactersCountLabel.text = "\(textView.text.characters.count) / \(groupDescriptionCharactersLimit)"
	}
	
	
	// MARK: - UIImagePickerControllerDelegate
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
		
		let image = image.scaledToSize(Constants.Values.ProfilePictureSize)
		groupImage.image = image
		
		groupImage.contentMode = .ScaleAspectFill
		imageOverLabelConstraint.active = true
		
		pictureChanged = true
		
	}
	
	
	// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		if pickerView == clubTypePicker
		{
			return CampusGroup.GroupType.All.count
		} else if pickerView == recognizedTypePicker
		{
			return CampusGroup.SchoolRecognizedGroupType.All.count
		}
		
		return 0
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
	{
		if pickerView == clubTypePicker
		{
			return CampusGroup.GroupType.All[row].rawValue
		} else if pickerView == recognizedTypePicker
		{
			return CampusGroup.SchoolRecognizedGroupType.All[row].rawValue
		}
		
		return nil
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		guard let group = group
			else
		{
			fatalError("Create new group in viewDidLoad first")
		}
		
		if pickerView == clubTypePicker
		{
			group.groupType = CampusGroup.GroupType.All[row]
			
			if CampusGroup.GroupType.All[row] == .SchoolRecognized
			{
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.recognizedTypePicker.hidden = false
				}
			} else
			{
				group.recognizedGroupType = nil
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.recognizedTypePicker.hidden = true
				}
			}
		} else if pickerView == recognizedTypePicker
		{
			group.recognizedGroupType = CampusGroup.SchoolRecognizedGroupType.All[row]
		}
	}
	
    // MARK: - Private
	
	private func createNewGroup()
	{
		guard let group = group
			else
		{
			fatalError("Create new group in viewDidLoad first")
		}
		group.name = nameField.text
		group.description = descriptionTextView.text
		
		group.president = presidentField.text
		group.executive = executiveField.text
		group.executive2 = executive2Field.text
		group.executive3 = executive3Field.text
		
		CampusGroupRequest.createNewGroup(group, owner: CampusUser.currentUser,
			successHandler: { (group) -> () in
				self.activityIndicator.stopAnimating()
				self.group = group
				
				// For ease of implementation, first create group and then add image for it.
				if self.pictureChanged == true
				{
					self.uploadGroupPicture()
				}
				
				let alertController = UIAlertController(title: "Success", message: "Group created and you are now the admin!", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
					let myGroupsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(MyGroupsViewController.storyboardId) as! MyGroupsViewController
					let addMembersController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(AddGroupMembersViewController.storyboardId) as! AddGroupMembersViewController
					addMembersController.group = group
					
					if let navController = self.navigationController
					{
						navController.pushViewController(addMembersController, animated: true)
						navController.viewControllers[navController.viewControllers.count - 2] = myGroupsController
					} else
					{
						fatalError("This controller is supposed to be used from inside of a navigation controller. Adhere or implement alternative workflow.")
					}
				}
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				if case .StatusCode(let statusCode, let message) = error where statusCode == 422
				{
					let alertController = UIAlertController(title: "Could not create new group", message: message, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
				} else
				{
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				}
		})

	}

	private func editGroup()
	{
		if let group = group
		{
			group.description = descriptionTextView.text
			group.name = nameField.text
			
			group.president = presidentField.text
			group.executive = executiveField.text
			group.executive2 = executive2Field.text
			group.executive3 = executive3Field.text
			
			CampusGroupRequest.editGroup(group,
				successHandler: { (group) -> () in
					self.activityIndicator.stopAnimating()
					
					if self.pictureChanged == true
					{
						self.uploadGroupPicture()
					}
					
					let alertController = UIAlertController(title: "Group updated", message: nil, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else
		{
			fatalError("Trying to edit group, but group is nil?")
		}
	}
	
	private func uploadGroupPicture()
	{
		guard let image = groupImage.image
			else
		{
			log.error("Updating with a nil image??")
			return
		}
		
		guard let group = group
			else
		{
			fatalError("Group is nil?? Group must be created first, before updating with picture path")
		}
		
		let uuid = NSUUID().UUIDString
		let pictureURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("group_pictures/\(uuid).jpg")
		
		UIImageJPEGRepresentation(image, 0.8)!.writeToURL(pictureURL, atomically: false)
		
		group.uploadGroupPictureToS3FromLocalURL(pictureURL,
			uuid: uuid,
			successHandler: { () -> () in
				group.deleteGroupPictureFromS3() // profilePicturePath is still the old value, so currently there are two profile picture for this user - one with old, one with new!
				group.groupPicturePath = "group_pictures/\(uuid).jpg"

				CampusGroupRequest.updateGroupPicture(group,
					successHandler: { () -> () in
						// Write in background so not to block UI
						let qualityOfServiceClass = QOS_CLASS_BACKGROUND
						let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
						dispatch_async(backgroundQueue) {
							let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("group_pictures/\(uuid).jpg")
							UIImageJPEGRepresentation(image, 0.8)?.writeToURL(cachedURL, atomically: false)
						}
					},
					failureHandler: { (error) -> () in
						let alertController = UIAlertController(title: "Could not upload the group picture.", message: "Please try again later.", preferredStyle: .Alert)
						let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
						alertController.addAction(okAction)
						
						self.presentViewController(alertController, animated: true, completion: nil)
				})
			},
			errorHandler: { (error) -> () in
				let alertController = UIAlertController(title: "Could not upload the group picture.", message: "Please try again later.", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
		})

	}
}
