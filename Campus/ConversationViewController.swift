//
//  ConversationViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/6/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

// TODO: Chat abstraction model

class ConversationViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
	static let storyboardId = "ConversationViewController"
	static private let toAddRecipientsSegueId = "conversationToAddRecipients"
	
	// MARK: - Properties
	var conversation: CampusConversation!
	var messages = [CampusPrivateMessage]()
	
	var newMessageRecipients: [CampusUser]?
	
	private var lastMessageId: Int?
	
	private var lastMessageDate = NSDate(timeIntervalSince1970: 1)
	private let dateFormatter = NSDateFormatter()
	
	private var newMessagesObserver: NSObjectProtocol!
	
	private var titleTextField = UITextField()
	// MARK: - Outlets
	
	@IBOutlet var titleButton: UIButton!
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var messageTextView: UITextView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!

	@IBOutlet var separatorHeight: NSLayoutConstraint!
	
	// MARK: - Actions
	
	@IBAction func searchPressed(sender: UIBarButtonItem)
	{
	}
	
	@IBAction func titlePressed(sender: UIButton)
	{
		titleTextField.frame = titleButton.frame
		titleTextField.text = conversation.title
		
		self.navigationItem.titleView = titleTextField
		
		titleTextField.becomeFirstResponder()
	}
	
	@IBAction func addRecipients(sender: UIStoryboardSegue)
	{
		if let newMessageRecipients = newMessageRecipients
		{
			activityIndicator.startAnimating()
			CampusConversationsRequest.addParticipants(newMessageRecipients,
				toConversation: conversation,
				successHandler: { (conversation) -> () in
					self.conversation = conversation
					
					self.updateTitle()
					self.activityIndicator.stopAnimating()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
		
		titleTextField.backgroundColor = UIColor.clearColor()
		titleTextField.textColor = UIColor.whiteColor()
		titleTextField.delegate = self
		
		updateTitle()
		
		separatorHeight.constant = 0.5
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 72 //IB derived for one line message
		
		dateFormatter.dateFormat = "EEE, MMM dd, hh:mm a"
		
		messageTextView.text = Constants.Strings.EnterMessagePlaceholder
		messageTextView.textColor = UIColor.lightGrayColor()
    }
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		if conversation.id != -1
		{
			fetchMessages(unreadOnly: true)
		}
		
		newMessagesObserver = NSNotificationCenter.defaultCenter().addObserverForName(Constants.NotificationIds.NotificationNewPrivateMessage, object: nil, queue: nil) { (notification) -> Void in
			guard let newMessage = notification.userInfo?["message"] as? CampusPrivateMessage
				else
			{
				log.error("No message in notification!")
				return
			}
			
			if self.conversation.participants.map({ $0.id }).contains(newMessage.sender.id)
			{
				self.fetchMessages(unreadOnly: true)
			}
		}
	}
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(newMessagesObserver)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? UINavigationController
			where segueId == ConversationViewController.toAddRecipientsSegueId
		{
			let destVC = destVC.viewControllers[0] as! ComposeNewMessageViewController
			destVC.addingToNewConversation = false
			destVC.existingParticipants = conversation.participants
		}
	}
	
	
	// MARK: - UITextFieldDelegate
	
	// Only for changing the title
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		if textField == titleTextField
		{
			self.navigationItem.titleView = titleButton
			
			conversation.title = textField.text
			if conversation.id >= 0
			{
				activityIndicator.startAnimating()
				CampusConversationsRequest.updateConversation(conversation,
					successHandler: { (conversation) -> () in
						self.conversation = conversation
						self.updateTitle()
						self.activityIndicator.stopAnimating()
					},
					failureHandler: { (error) -> () in
						self.activityIndicator.stopAnimating()
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			}
		}
		
		return true
	}
	
	// MARK: - UITextViewDelegate
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
	{
		guard let messageText = textView.text where messageText.stringByReplacingOccurrencesOfString(" ", withString: "") != ""
			else
		{
			return text != "\n" //Don't allow new line characters when there is no text
		}
		
		if messageText == "" && text == "\n" //Don't allow new line characters when there is no text
		{
			return false
		}
		
		if text != "\n" // Not enter/send - return and append new text
		{
			return true
		}
		
		// Current text is non-empty string, new text is "\n" - user pressed Enter (phys kb) or Send (touck kb)
		
		self.activityIndicator.startAnimating()
		
		if conversation.id == -1 // First message in a new conversation
		{
			CampusConversationsRequest.createConversation(conversation,
				successHandler: { (conversation) -> () in
					self.conversation = conversation
					self.sendMessage(messageText)
					textView.text = nil
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else
		{
			self.sendMessage(messageText)
			textView.text = nil
		}
		
		return false
	}
	
	func textViewDidBeginEditing(textView: UITextView)
	{
		if let text = textView.text where text == Constants.Strings.EnterMessagePlaceholder
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
			textView.text = Constants.Strings.EnterMessagePlaceholder
			textView.textColor = UIColor.lightGrayColor()
		}
		textView.resignFirstResponder()
	}
	
	// MARK: - UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return messages.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let message = messages[indexPath.row]
		
		if message.sender.id == CampusUser.currentUser.id
		{
			let cell = tableView.dequeueReusableCellWithIdentifier(ConversationSentTableCell.reuseId, forIndexPath: indexPath) as! ConversationSentTableCell
			cell.message.text = message.text
			cell.message.layer.cornerRadius = 10
			
			if lastMessageDate.isDifferentDayFrom(message.sentDate)
			{
				cell.conversationDate.text = dateFormatter.stringFromDate(message.sentDate)
			} else
			{
				cell.conversationDate.text = nil
			}
			
			lastMessageDate = message.sentDate
			return cell
		} else
		{
			let cell = tableView.dequeueReusableCellWithIdentifier(ConversationReceivedTableCell.reuseId, forIndexPath: indexPath) as! ConversationReceivedTableCell
			cell.message.text = message.text
			cell.message.layer.cornerRadius = 10
			cell.conversationDate.text = nil
			
			cell.senderName.text = message.sender.firstName + " " + message.sender.lastName
			message.sender.getProfilePictureFromS3(handler: { (image) -> () in
				if let visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
				{
					if let image = image
					{
						cell.thumbnail.image = image
					} else
					{
						cell.thumbnail.image = UIImage(named: Constants.Values.NoPhotoImageName)
					}

				}
			})
			
			if lastMessageDate.isDifferentDayFrom(message.sentDate)
			{
				cell.conversationDate.text = dateFormatter.stringFromDate(message.sentDate)
			} else
			{
				cell.conversationDate.text = nil
			}
			
			lastMessageDate = message.sentDate
			return cell
		}
		
		
	}
	
	
	// MARK: - Private
	
	private func sendMessage(messageText: String)
	{
		CampusConversationsRequest.createMessageWithText(messageText,
			inConversation: conversation,
			successHandler: { (message) -> () in
				self.messages.append(message)
				
				self.tableView.reloadData()
				self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0),
					atScrollPosition: .Top, animated: true)
				
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				
		})
	}
	
	private func fetchMessages(unreadOnly unread: Bool)
	{
		activityIndicator.startAnimating()
		CampusConversationsRequest.getMessagesInConversation(conversation,
			sinceMessageId: lastMessageId,
			successHandler: { (messages) -> () in
				if unread == false
				{
					self.messages.removeAll()
				} else
				{
					self.messages = self.existingMessagesFilteredWithNew(messages)
				}
				
				self.messages += messages.sort { $0.sentDate < $1.sentDate }
				self.tableView.reloadData()
				if self.messages.count >= 1
				{
					self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0),
						atScrollPosition: .Bottom, animated: false)
					if let message = messages.last
					{
						self.lastMessageId = message.id
					}
				}
				
				if unread
				{
					UIApplication.sharedApplication().applicationIconBadgeNumber -= self.messages.count
					if let countString = self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue, count = Int(countString)
					{
						if count - self.messages.count > 0
						{
							self.self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = "\(count - self.messages.count)"
						} else
						{
							self.self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = nil
						}
					}
				}
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	//Remove existing messages if they are also in the upcoming updated set to avoid duplicates
	private func existingMessagesFilteredWithNew(newMessages: [CampusPrivateMessage]) -> [CampusPrivateMessage]
	{
		return messages.filter { !newMessages.map{$0.id}.contains($0.id) }
	}
	
	private func updateTitle()
	{
		if let title = conversation.title
		{
			self.titleButton.setTitle(title, forState: .Normal)
		} else
		{
			var title = ""
			for user in conversation.participants
			{
				title += user.firstName + " " + user.lastName
				title += ", "
			}
			title = title.substringToIndex(title.endIndex.predecessor().predecessor()) // Trim last ", "
			self.titleButton.setTitle(title, forState: .Normal)
		}

	}
}
