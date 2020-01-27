//
//  RegisterAboutViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/4/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import AWSS3

class ProfileEditAboutViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	// MARK: - Properties
	static let storyboardId = "ProfileEditAboutViewController"
	
	private let imagePicker = UIImagePickerController()
	private let aboutTextCharactersLimit = 250
	
	private var pictureChanged = false
	private var birthdaySelected = false
	
	
	// MARK: - Outlets
	
	@IBOutlet var profilePictureImageView: UIImageView!
	@IBOutlet var addYourPhoto: UILabel!
	
	@IBOutlet var aboutTextContainer: UIView!
	@IBOutlet var aboutTextView: UITextView!
	@IBOutlet var aboutLettersCountLabel: UILabel!
	
	@IBOutlet var majorField: UITextField!
	@IBOutlet var bioField: UITextField!
	@IBOutlet var dreamJobField: UITextField!
	@IBOutlet var hobbiesField: UITextField!
	@IBOutlet var quoteField: UITextField!
	@IBOutlet var birthdayPicker: UIDatePicker!
	
	@IBOutlet var submitButton: UIButton!
	
	@IBOutlet var imageLargeSizeConstraint: NSLayoutConstraint!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func changePicturePressed(sender: UIButton)
	{
		imagePicker.allowsEditing = true
		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func birthdayChanged(sender: UIDatePicker)
	{
		birthdaySelected = true
	}
	
	@IBAction func submitPressed(sender: UIButton)
	{
		UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
			self.activityIndicator.startAnimating()
		}
		
		CampusUser.currentUser.about = aboutTextView.text
		CampusUser.currentUser.major = majorField.text
		CampusUser.currentUser.bio = bioField.text
		CampusUser.currentUser.dreamJob = dreamJobField.text
		CampusUser.currentUser.hobbies = hobbiesField.text
		CampusUser.currentUser.favouriteQuote = quoteField.text
		
		if birthdaySelected
		{
			CampusUser.currentUser.birthday = birthdayPicker.date
		}
		
		CampusUserRequests.updateUser(
			CampusUser.currentUser,
			successHandler: { (user) -> () in
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.activityIndicator.stopAnimating()
				}
				
				if self.pictureChanged == true
				{
					self.uploadProfilePicture()
				}
				
				CampusUser.currentUser = user
				
				if CampusUser.currentUser.firstLogin
				{
					self.navigationController?.popViewControllerAnimated(true)
				} else
				{
					let alertController = UIAlertController(title: "Profile updated", message: nil, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
				}
				
			}, failureHandler: { (error) -> () in
				UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
					self.activityIndicator.stopAnimating()
				}
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		imagePicker.delegate = self
		
		if UIScreen.mainScreen().nativeBounds.height < 1333
		{
			NSLayoutConstraint.deactivateConstraints([imageLargeSizeConstraint])
		}
		
		aboutTextContainer.layer.borderWidth = 0.5
		aboutTextContainer.layer.borderColor = Constants.Colors.DefaultTextFieldBorderColor.CGColor
		aboutTextContainer.layer.cornerRadius = 5
		
		aboutTextView.delegate = self
		profilePictureImageView.clipsToBounds = true
		
		if CampusUser.currentUser.about != ""
		{
			self.aboutTextView.text = CampusUser.currentUser.about
		}
		
		aboutTextView.text = CampusUser.currentUser.about
		majorField.text = CampusUser.currentUser.major
		bioField.text = CampusUser.currentUser.bio
		dreamJobField.text = CampusUser.currentUser.dreamJob
		hobbiesField.text = CampusUser.currentUser.hobbies
		quoteField.text = CampusUser.currentUser.favouriteQuote
		
		if let date = CampusUser.currentUser.birthday
		{
			birthdayPicker.date = date
		}
		
		CampusUser.currentUser.getProfilePictureFromS3 { (image) -> () in
			if let image = image
			{
				self.profilePictureImageView.image = image
				self.addYourPhoto.hidden = true
			}
		}
		
		textViewDidChange(aboutTextView)
    }

	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		submitButton.layer.cornerRadius = submitButton.frame.size.height / 2
	}
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func textViewDidChange(textView: UITextView)
	{
		if textView.text.characters.count > aboutTextCharactersLimit
		{
			textView.text = textView.text.substringToIndex(textView.text.startIndex.advancedBy(aboutTextCharactersLimit))
		}
		
		aboutLettersCountLabel.text = "\(textView.text.characters.count) / \(aboutTextCharactersLimit)"
	}
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
	{
		let currentCharacterCount = textView.text?.characters.count ?? 0
		
		if (range.length + range.location > currentCharacterCount)
		{
			return false
		}
		
		let newLength = currentCharacterCount + text.characters.count - range.length
		
		return newLength <= aboutTextCharactersLimit
	}
	
	func textViewDidBeginEditing(textView: UITextView)
	{
		if textView.text == "Welcome to CampUs! Make sure you fill out your profile here and then check out the menu on the top left to start finding and creating groups!"
		{
			textView.text = ""
		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - UIImagePickerControllerDelegate
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
		
		let image = image.scaledToSize(Constants.Values.ProfilePictureSize)
		profilePictureImageView.image = image
		
		pictureChanged = true
	}
	
	
	// MARK: - Private
	
	private func uploadProfilePicture()
	{
		guard let image = profilePictureImageView.image
			else
		{
			return
		}
		
		let uuid = NSUUID().UUIDString
		let pictureURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("profile_pictures/\(uuid).jpg")
		
		UIImageJPEGRepresentation(image, 0.8)!.writeToURL(pictureURL, atomically: false)
		
		CampusUser.currentUser.uploadProfilePictureToS3FromLocalURL(pictureURL,
			uuid: uuid,
			successHandler: { () -> () in
				CampusUser.currentUser.deleteProfilePictureFromS3() // profilePicturePath is still the old value, so currently there are two profile picture for this user - one with old, one with new!
				CampusUser.currentUser.profilePicturePath = "profile_pictures/\(uuid).jpg"
				
				CampusUserRequests.updateUserPicture(CampusUser.currentUser,
					successHandler: { () -> () in
						let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("profile_pictures/\(uuid).jpg")
						UIImageJPEGRepresentation(image, 0.8)?.writeToURL(cachedURL, atomically: false)
					}, failureHandler: { (error) -> () in
						let alertController = UIAlertController(title: "Could not upload the profile picture.", message: "Please try again later.", preferredStyle: .Alert)
						let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
						alertController.addAction(okAction)
						
						self.presentViewController(alertController, animated: true, completion: nil)
				})
			},
			errorHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				let alertController = UIAlertController(title: "Error uploading photo", message: "Please try again later.", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
		})

	}
}
